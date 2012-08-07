require 'tmpdir'

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

      ##
      # A temporary directory for installing the executable to
      def tmp_dir
        @tmp_dir ||= Dir.mktmpdir
        File.expand_path(@tmp_dir)
      end

    end
  end
end

