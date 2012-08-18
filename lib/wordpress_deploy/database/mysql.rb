require 'tmpdir'

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

      def mysqldump
        "#{utility("mysqldump")} #{arguments}"
      end

      private

      def arguments
        "-P \"#{port}\" -h \"#{host}\" -u \"#{user}\" -p#{password} -B \"#{name}\""
      end

      ##
      # A temporary directory for installing the executable to
      def tmp_dir
        @tmp_dir ||= Dir.mktmpdir
        File.expand_path(@tmp_dir)
      end

    end
  end
end

