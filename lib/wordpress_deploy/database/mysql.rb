require 'tempfile'

module WordpressDeploy
  module Database

    class MySql
      include WordpressDeploy::Cli::Helpers

      def initialize
        @user       ||= "root"
        @password   ||= ""

        @host       ||= "localhost"
        @port       ||= 3306
        @socket     ||= ""
        @name       ||= "wordpress"

        @has_port   ||= true
        @has_socket ||= false
      end

      ##
      # Name of the database (DB_NAME)
      def name(new_name = nil)
        @name = new_name.to_s unless new_name.nil?
        @name
      end

      ##
      # User credentials for the specified database
      def user(new_user = nil)
        @user = new_user.to_s unless new_user.nil?
        @user
      end

      ##
      # Password credentials for the specified database
      def password(new_password = nil)
        @password = new_password.to_s unless new_password.nil?
        @password
      end

      ##
      # Get just the hostname from DB_HOST. Only different from
      # DB_HOST if DB_HOST has a socket or a port number in it.
      def host(new_host = nil)
        unless new_host.nil?
          match = /(?<host>.*?)(?=:|\z)(:(?<socket>\/.*)|:(?<port>\d+))?/.match(new_host.to_s)
          @host = match[:host].to_s unless match[:host].nil?

          # Set the socket information
          if @has_socket = !match[:socket].nil?
            @has_socket = true
            @socket = match[:socket]
          end

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

      ##
      # This value should be able to be plugged directly into
      # DB_HOST int he wp-config.php file.
      def wp_host
        extra = nil
        extra = ":#{socket}" if socket?
        extra = ":#{port}" if port?
        "#{host}#{extra}"
      end

      ##
      # Extract just the port number from the DB_HOST
      # configuration file. Or return the default port of 3306.
      def port
        @port
      end

      ##
      # Does DB_HOST contain a port number? (it does if one was
      # specified and it does not equal 3306; the default MySQL
      # port number.
      def port?
        @has_port && port != 3306
      end

      ##
      # Extract just the socket part from the DB_HOST
      # configuration file. Or return an empty string if none.
      def socket
        @socket
      end

      ##
      # Does DB_HOST contain a socket path?
      def socket?
        @has_socket
      end

      def charset(new_charset = nil)
        @charset = new_charset.to_s unless new_charset.nil?
        @charset
      end

      def collate(new_collate = nil)
        @collate = new_collate.to_s unless new_collate.nil?
        @collate
      end

      def table_prefix(new_prefix = nil)
        @prefix = new_prefix.to_s unless new_prefix.nil?
        @prefix
      end

      ##
      # The file that the instance would save to if
      # save is called.
      def file
        File.join(Config.sql_dir, "#{name}.sql")
      end

      ##
      # Save the database to a file locally.
      #
      # The database will be output into #file.
      def save!
        # Get the output from MySQL Dump
        cmd = mysqldump
        dump_str = run cmd

        # Open the supplied file; or create a temporary one
        file_io = File.new(file, 'w')

        # Start writing to file
        file_io.write(dump_str)

        true
      ensure
        file_io.close unless file_io.nil?
      end

      ##
      #
      def send!(to_config_name)
        # Check to see if there is a SQL file
        if File.exists? file
          # Create the 'to' configuration
          mysql = self.class.new(to_config_name)

          # Open the source sql file for reading
          tmp_file = Tempfile.new(["#{to_config_name}", '.sql'])

          # Write sql to tmpfile while changing the
          # the CREATE DATABASE and USE commands to make sense for
          # the 'to' configuration
          sql_dump = File.read(file)
          sql_dump.gsub!(/^USE\ `#{self.DB_NAME}`/, "USE `#{mysql.DB_NAME}`")
          tmp_file.puts sql_dump

          # Get the MySQL load command
          cmd = mysqlload to_config_name, tmp_file.path

          # Run the mysql command to load the mysqldump into
          # the destination mysql instance
          run cmd
        end
      ensure
        # Delete the temp file unless it was never made
        tmp_file.unlink unless tmp_file.nil?
      end

      private

      def mysqldump
        arguments = "-P \"#{port}\" -h \"#{host}\" -u \"#{user}\" -p\"#{password}\" -B \"#{name}\""
        "#{utility("mysqldump")} #{arguments}"
      end

      def mysqlload(config_name, file_name)
        mysql = self.class.new config_name
        arg_port = mysql.db_port
        arg_host = mysql.db_hostname
        arg_user = mysql.DB_USER
        arg_pass = mysql.DB_PASSWORD
        arg_name = mysql.DB_NAME
        arguments = "-P \"#{arg_port}\" -u \"#{arg_user}\" -h \"#{arg_host}\" -p\"#{arg_pass}\" -D \"#{arg_name}\""

        "#{utility("mysql")} #{arguments} < #{file_name}"
      end

    end
  end
end

