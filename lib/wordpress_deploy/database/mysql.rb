require 'tempfile'
require 'sequel'
require 'mysql2'
require 'php_serialize'
require 'shellwords'

module WordpressDeploy
  module Database

    class MySql
      include WordpressDeploy::Cli::Helpers

      attr_reader :env
      alias :environment :env

      def initialize(environment)
        @env = environment
        @db = Sequel.mysql(
          adapter: "mysql2",
          host:     @env.host,
          user:     @env.user,
          password: @env.password,
          port:     @env.port,
          database: @env.name,
          encoding: @env.charset
        )
      end

      ##
      # Test the connection to the database defined by this environment. It
      # returns true if a connection can be made; false otherwise.
      def connection?
        @db.test_connection
      rescue
        false
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
        file_io = File.new(env.file, 'w')

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
          tmp_file = Tempfile.new(["#{to_db.name}", '.sql'])

          # Open the source sql file for reading
          sql_dump = File.read(file)

          # Write sql to tmpfile while changing the
          # the CREATE DATABASE and USE commands to make sense for
          # the 'to' configuration
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
        arguments = "-P \"#{env.port}\" -h \"#{env.host}\" -u \"#{env.user}\" -p\"#{Shellwords.escape(env.password)}\" -B \"#{env.name}\""
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

