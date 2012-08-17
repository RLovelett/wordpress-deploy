require 'tempfile'

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

