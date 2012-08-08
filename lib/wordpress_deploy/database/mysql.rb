require 'tmpdir'

module WordpressDeploy
  module Database

    class MySql
      include WordpressDeploy::Cli::Helpers

      attr_reader :configuration

      def initialize
        @yaml     = YAML.load_file(File.join(Environment.config_dir, "wp-config.yml"))
      end

      def mysqldump
        "#{utility("mysqldump")} #{arguments}"
      end

      def configuration=(new_config)
        @configuration = new_config if new_config.instance_of? WordpressDeploy::Wordpress::Configuration
      end

      private

      def arguments
        host = configuration.host
        port = configuration.port
        username = configuration.DB_USER
        password = configuration.DB_PASSWORD
        db_name = configuration.DB_NAME

        "-P \"#{port}\" -h \"#{host}\" -u \"#{username}\" -p#{password} -B \"#{db_name}\""
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

