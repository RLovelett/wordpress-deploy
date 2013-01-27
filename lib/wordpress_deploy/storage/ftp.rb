##
# Only load the Net::FTP library/gem when the
# WordpressDeploy::Storage::Ftp class is loaded
require "net/ftp"
require "pathname"
require "action_view"

module WordpressDeploy
  module Storage
    class Ftp
      include ActionView::Helpers::NumberHelper

      ##
      # Create a new instance of the Ftp object
      def initialize(&block)
        @host        ||= "localhost"
        @port        ||= 21
        @user        ||= "root"
        @password    ||= ""
        @destination ||= "/"

        instance_eval(&block) if block_given?
      end

      ##
      # Check if there is an open connection.
      #
      # Captures all exceptions that would be raised; returns false in the
      # of any exception being raised.
      #
      # Returns true only if the connection is open, false otherwise.
      def open?
        !ftp.closed?
      rescue Net::FTPConnectionError
        false
      end

      ##
      # An array of the files in the configured Wordpress directory.
      def files
        Dir.glob(File.join(Config.wp_dir, "**/*")).sort
      end

      def host(new_host = nil)
        unless new_host.nil?
          match = /(?<host>.*?)(?=:|\z)(:(?<port>\d+))?/.match(new_host.to_s)
          @host = match[:host].to_s unless match[:host].nil?

          # Set the port information
          unless match[:port].nil?
            @port = match[:port].to_i
          end

          # Has port is true; unless a socket was set
          @has_port = !@has_socket
        end

        # return the host
        @host
      end

      def port
        @port
      end

      def user(new_user = nil)
        @user = new_user.to_s unless new_user.nil?
        @user
      end

      def password(new_pass = nil)
        @password = new_pass.to_s unless new_pass.nil?
        @password
      end

      def destination(new_dest = nil)
        @destination = new_dest.to_s unless new_dest.nil?
        @destination
      end

      ##
      # If the connection is open, close it
      # Returns true if the connection is closed; false otherwise
      def close
        unless ftp.closed?
          ftp.close
          return true
        end
        return false
      end

      def transmit
        raise NotImplementedError
      end

      ##
      #
      def transmit!
        connect
        files.each do |file|
          put_file file
        end
      ensure
        close
      end

      def receive
        raise NotImplementedError
      end

      def receive!(path=remote_path)
        # Where did it start from
        pwd = ftp.pwd

        # Change to the remote path
        chdir(path)

        # Get a list of all the files
        # and directories in the current pwd
        files = ftp.nlst ftp.pwd

        # Remove the 'dot' directories
        files.delete(".")
        files.delete("..")

        # Create a relative pathname
        rel_remote_path = Pathname.new(ftp.pwd).relative_path_from Pathname.new(remote_path)

        # Loop through each file and directory
        # found in the current pwd
        files.each do |file|

          # Build the file name to save it to
          local_file = Pathname.new(File.join(Config.wp_dir, rel_remote_path, File.basename(file))).cleanpath.to_s
          if directory? file
            Logger.debug "[mkdir] #{local_file}"
            FileUtils.mkdir_p local_file
            receive! file
          else
            str = "[cp] #{file} (#{self.number_to_human_size(ftp.size(file), precision: 2)})"
            ftp.getbinaryfile(file, local_file)
            Logger.debug str
          end
        end

        # Return from whence we came
        chdir(pwd)

      end

      private

      def ftp
        @ftp ||= Net::FTP.new
        @ftp
      end

      ##
      # Establish a connection to the remote server
      def connect
        ftp.connect(host, port)
        ftp.login(user, password)
        ftp.passive = true
        # ftp.debug_mode = true
        #chdir(destination)
      end

      ##
      # Put file on remote machine
      def put_file(real_path)
        pn = Pathname.new(real_path)
        relative = pn.relative_path_from Pathname.new(Config.wp_dir)

        # Only try to send files; no directories
        unless pn.directory?
          local_directory, local_file_name = relative.split
          remote_directory = Pathname.new("#{destination}/#{local_directory}").cleanpath.to_s

          begin
            # Make sure to be in the right directory
            chdir remote_directory

            # Now send the file (overwriting if it exists)
            write_file(real_path, local_file_name.to_s, true)
          rescue Net::FTPPermError; end
        end
      end

      def write_file(local_file, remote_file_name, overwrite)
        begin
          str = "[cp] #{remote_file_name} (#{self.number_to_human_size(File.size(local_file), precision: 2)})"
          ftp.putbinaryfile(local_file, remote_file_name)
          Logger.debug str
        rescue Net::FTPPermError => e
          if ftp.last_response_code.to_i === 550 and overwrite
            ftp.delete(remote_file_name)
            ftp.putbinaryfile(real_path, remote_file_name)
            Logger.debug "#{str} - OVERWRITING"
          end
        end
      end

      ##
      # Check that directory path exists on the FTP site
      def directory?(directory)
        pwd = ftp.pwd
        begin
          ftp.chdir(directory)
          return true
        rescue Net::FTPPermError
          return false
        end
      ensure
        ftp.chdir pwd
      end

      ##
      # Change the current working directory
      def chdir(directory)
        # If the current working directory does not
        # match the current working directory then
        # the directory must be changed
        if ftp.pwd != directory
          Logger.debug "[cd] #{directory}"
          # Make the requested directory if it does not exist
          mkdir(directory) unless directory?(directory)
          # Change into the requested directory
          ftp.chdir(directory)
        end
      end

      ##
      # Similar to mkdir -p.
      # It will make all the full directory path specified on the FTP site
      def mkdir(directory)
        pwd = ftp.pwd
        dirs = directory.split("/")
        dirs.each do |dir|
          begin
            ftp.chdir(dir)
          rescue Net::FTPPermError => e
            if ftp.last_response_code.to_i === 550
              Logger.debug "[mkdir] #{File.join(ftp.pwd, dir)}"
              ftp.mkdir(dir)
              ftp.chdir(dir)
            end
          end
        end
      ensure
        # Make sure to return to the directory
        # that was currently in use before the mkdir command
        # was issued
        ftp.chdir(pwd)
      end

    end
  end
end

