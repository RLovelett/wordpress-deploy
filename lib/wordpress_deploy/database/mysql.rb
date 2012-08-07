require 'tmpdir'

module WordpressDeploy
  module Database

    class MySql
      include WordpressDeploy::Cli::Helpers

      def initialize
        @yaml     = YAML.load_file(File.join(Environment.config_dir, "wp-config.yml"))
      end

      private

      def environment
        @yaml[Environment.environment]
      end

      def arguments
        "-P \"#{port}\" -h \"#{host}\" -u \"#{username}\" -p#{password} -B \"#{db_name}\""
      end

      def port
        port = 3306
        if environment.has_key? "DB_HOST"
          match = /:(?<port>\d+)$/.match(environment["DB_HOST"])
          port = match[:port].to_i unless match.nil?
        end
        port
      end

      def host
        host = "localhost"
        if environment.has_key? "DB_HOST"
          match = /(?<host>.*?)(?=:|$)/.match(environment["DB_HOST"])
          host = match[:host].to_s unless match.nil?
        end
        host
      end

      def username
        environment["DB_USER"]
      end

      def password
        environment["DB_PASSWORD"]
      end

      def db_name
        environment["DB_NAME"]
      end

      def executable_name
        File.expand_path File.join(tmp_dir, "pioneer_app")
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

