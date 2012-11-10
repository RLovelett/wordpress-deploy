require 'tempfile'
require 'sequel'
require 'mysql2'
require 'php_serialize'
require 'shellwords'

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

        @base_url   ||= @host
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
      #
      def base_url(new_url = nil)
        @base_url = new_url.to_s unless new_url.nil?
        @base_url
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
      def send!(to_env)
        # Get the MySql instance
        to_db = to_env.database

        # Check to see if there is a SQL file
        if File.exists? file
          # Open the source sql file for reading
          tmp_file = Tempfile.new(["#{to_db.name}", '.sql'])

          # Write sql to tmpfile while changing the
          # the CREATE DATABASE and USE commands to make sense for
          # the 'to' configuration
          sql_dump = File.read(file)
          sql_dump.gsub!(/^CREATE\ DATABASE.*$/i, "")
          sql_dump.gsub!(/^USE\ `#{name}`/, "USE `#{to_db.name}`")
          tmp_file.puts sql_dump

          # Get the MySQL load command
          cmd = mysqlload to_db, tmp_file.path

          # Run the mysql command to load the mysqldump into
          # the destination mysql instance
          run cmd
        end
      ensure
        # Delete the temp file unless it was never made
        tmp_file.unlink unless tmp_file.nil?
      end

      ##
      #
      def migrate!(to_env)
        # Get the MySql instance
        to_db = to_env.database

        client = Mysql2::Client.new(
          :host     => to_db.host,
          :username => to_db.user,
          :password => to_db.password,
          :port     => to_db.port,
          :database => to_db.name,
          #:socket = '/path/to/mysql.sock',
          :encoding => to_db.charset
        )

        # MySQL escape
        value_to_find = base_url
        value_to_replace = to_env.base_url
        escaped_value_to_find = client.escape(value_to_find)

        # wp_options option_value
        sql = <<-EOS
        SELECT `option_id`, `option_value`
        FROM `wp_options`
        WHERE `option_value` REGEXP '#{escaped_value_to_find}';
        EOS
        wp_options = client.query(sql)
        wp_options.each do |row|
          row.each do |key, value|
            if PHP.serialized?(value)
              ruby_php = PHP.unserialize(value)
              ruby_php.find_and_replace!(value_to_find, value_to_replace)
              value.replace PHP.serialize(ruby_php)
            else
              value.gsub!(/#{value_to_find}/, value_to_replace) if value.instance_of? String
            end
          end

          # Update the database
          sql = <<-EOD
          UPDATE `wp_options`
          SET `option_value`='#{client.escape(row['option_value'])}'
          WHERE `option_id` = #{row['option_id']};
          EOD
          Logger.debug sql
          client.query(sql)
        end

        # wp_posts post_content, guid
        sql = <<-EOS
        SELECT `ID`, `post_content`, `guid`
        FROM `wp_posts`
        WHERE `post_content` REGEXP '#{escaped_value_to_find}'
        AND   `guid`         REGEXP '#{escaped_value_to_find}';
        EOS
        wp_posts = client.query(sql)
        wp_posts.each do |row|
          row.each do |key, value|
            if PHP.serialized?(value)
              ruby_php = PHP.unserialize(value)
              ruby_php.find_and_replace!(value_to_find, value_to_replace)
              value.replace PHP.serialize(ruby_php)
            else
              value.gsub!(/#{value_to_find}/, value_to_replace) if value.instance_of? String
            end
          end
          sql = <<-EOD
          UPDATE `wp_posts`
          SET `post_content` = '#{client.escape(row['post_content'])}',
          `guid` = '#{client.escape(row['guid'])}'
          WHERE `ID` = #{row['ID']};
          EOD
          Logger.debug sql
          client.query(sql)
        end

        # wp_postmeta
        sql = <<-EOS
        SELECT `meta_id`, `meta_value`
        FROM `wp_postmeta`
        WHERE `meta_value` REGEXP '#{escaped_value_to_find}';
        EOS
        wp_postmeta = client.query(sql)
        wp_postmeta.each do |row|
          row.each do |key, value|
            if PHP.serialized?(value)
              ruby_php = PHP.unserialize(value)
              ruby_php.find_and_replace!(value_to_find, value_to_replace)
              value.replace PHP.serialize(ruby_php)
            else
              value.gsub!(/#{value_to_find}/, value_to_replace) if value.instance_of? String
            end
          end
          sql = <<-EOD
          UPDATE `wp_postmeta`
          SET `meta_value` = '#{client.escape(row['meta_value'])}'
          WHERE `meta_id` = #{row['meta_id']};
          EOD
          Logger.debug sql
          client.query(sql)
        end
      end

      private

      def mysqldump
        arguments = "-P \"#{port}\" -h \"#{host}\" -u \"#{user}\" -p\"#{Shellwords.escape(password)}\" -B \"#{name}\""
        "#{utility("mysqldump")} #{arguments}"
      end

      def mysqlload(database, file_name)
        arg_port = database.port
        arg_host = database.host
        arg_user = database.user
        arg_pass = database.password
        arg_name = database.name
        arguments = "-P \"#{arg_port}\" -u \"#{arg_user}\" -h \"#{arg_host}\" -p\"#{Shellwords.escape(arg_pass)}\" -D \"#{arg_name}\""

        "#{utility("mysql")} #{arguments} < #{file_name}"
      end

    end
  end
end

