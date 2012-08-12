##
# Only load the Net::FTP library/gem when the
# WordpressDeploy::TransferProtocols::Ftp class is loaded
require "net/ftp"
require "pathname"
require "action_view"

module WordpressDeploy
  module TransferProtocols
    class Ftp
      include ActionView::Helpers::NumberHelper

      attr_reader :configuration
      attr_accessor :available_names
      alias :names :available_names

      ##
      # Create a new instance of the Ftp object
      def initialize(config_name = nil)
        # Set the configuration
        @yaml             = YAML.load_file(File.join(Environment.config_dir, "wp-config.yml"))
        @available_names  = @yaml.map { |key, val| key }

        self.name = config_name unless config_name.nil?

        # Actually open the connection
        connect
      end

      def configuration=(new_config)
        @configuration = new_config if new_config.instance_of? WordpressDeploy::Wordpress::Configuration
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
        files = Dir.glob(File.join(Environment.wp_dir, "**/*")).sort
        files.each do |file|
          put_file file
        end
      end

      def receive
        raise NotImplementedError
      end

      def receive!

      end

      ##
      # Return the configuration's name.
      #
      # Defaults to the first configuration name.
      def name
        @name ||= available_names.first
        @name
      end

      ##
      # Set the configuration's name.
      #
      # Only performs the assignment if the proposed name is
      # an available name.
      #
      # Returns the Configuration's name.
      def name=(new_name)
        @name = new_name if name? new_name
        @name
      end

      ##
      # Test if the name passed in is an available configuration
      # name.
      def name?(name_to_check)
        available_names.include? name_to_check
      end

      def local_path
        Environment.wp_dir
      end

      def remote_path
        ftp_dir = send(:FTP_DIR)
        return "/" if ftp_dir.nil?
        ftp_dir
      end

      def username
        send(:FTP_USER) || ""
      end

      def password
        send(:FTP_PASSWORD) || ""
      end

      def port
        port = 21
        match = /:(?<port>\d+)$/.match(send(:FTP_HOST))
        port = match[:port].to_i unless match.nil?
        port
      end

      ##
      # Does FTP_HOST contain a port number?
      def port?
        !(send(:FTP_HOST) =~ /:(?<port>\d+)$/).nil?
      end

      ##
      # Get just the hostname from DB_HOST. Only different from
      # FTP_HOST if FTP_HOST has a port number in it.
      def host
        host = "localhost"
        match = /(?<host>.*?)(?=:|$)/.match(send(:FTP_HOST))
        host = match[:host].to_s unless match.nil?
        host
      end

      FTP_CONFIGURATION_ATTRIBUTES = [:FTP_DIR, :FTP_USER, :FTP_PASSWORD,
                                      :FTP_HOST]

      ##
      # Define the behaviours of the default parameters quickly
      def method_missing(meth, *args, &block)
        # Convert the method to a symbol
        method_symbol = meth.to_sym

        if FTP_CONFIGURATION_ATTRIBUTES.include? method_symbol
          config = @yaml[name]
          return config[meth.to_s] if config.include? meth.to_s
        else
          # You *must* call super if you don't handle the method, otherwise
          # you will mess up Ruby's method lookup.
          super
        end
      end

      ##
      # Define respond_to?
      def respond_to?(method)
        return true if FTP_CONFIGURATION_ATTRIBUTES.include? method.to_sym
        super
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
        ftp.login(username, password)
        ftp.passive = true
        # ftp.debug_mode = true
        #chdir(remote_path)
      end

      ##
      # Put file on remote machine
      def put_file(real_path)
        pn = Pathname.new(real_path)
        relative = pn.relative_path_from Pathname.new(Environment.wp_dir)

        # Only try to send files; no directories
        unless pn.directory?
          local_directory, local_file_name = relative.split
          remote_directory = Pathname.new("#{remote_path}/#{local_directory}").cleanpath.to_s

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

