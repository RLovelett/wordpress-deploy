require 'tempfile'
require 'mysql2'
require 'php_serialize'

module WordpressDeploy
  module Database

    class MySql
      include WordpressDeploy::ConfigurationFile
      include WordpressDeploy::Cli::Helpers

      ##
      # The file that the instance would save to if
      # save is called.
      def file
        File.join(Environment.sql_dir, "#{name}.sql")
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

      ##
      #
      def migrate!(to_config_name)
        mysql = self.class.new(to_config_name)

        client = Mysql2::Client.new(
          :host     => mysql.db_hostname,
          :username => mysql.DB_USER,
          :password => mysql.DB_PASSWORD,
          :port     => mysql.db_port,
          :database => mysql.DB_NAME,
          #:socket = '/path/to/mysql.sock',
          :encoding => mysql.DB_CHARSET
        )

        value_to_find = "localhost/~lindsey/huntsvillecrawfishboil.com"
        value_to_replace = "huntsvillecrawfishboil.com"
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
        arg_port = db_port
        arg_host = db_hostname
        arg_user = self.DB_USER
        arg_pass = self.DB_PASSWORD
        arg_name = self.DB_NAME
        arguments = "-P \"#{arg_port}\" -h \"#{arg_host}\" -u \"#{arg_user}\" -p\"#{arg_pass}\" -B \"#{arg_name}\""

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

