require 'tmpdir'

module WordpressDeploy
  module Database

    class MySql
      include WordpressDeploy::ConfigurationFile
      include WordpressDeploy::Cli::Helpers

      def mysqldump
        "#{utility("mysqldump")} #{arguments}"
      end

      private

      def arguments
        "-P \"#{db_port}\" -h \"#{db_hostname}\" -u \"#{self.DB_USER}\" -p#{self.DB_PASSWORD} -B \"#{self.DB_NAME}\""
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

