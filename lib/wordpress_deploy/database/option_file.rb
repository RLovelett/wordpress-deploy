require 'erb'
require 'tempfile'

module WordpressDeploy
  module Database
    class OptionFile
      ##
      # Create a MySQL option file
      def initialize(
        user,
        password,
        host,
        port,
        database,
        type = :mysql
      )
        @user = user
        @password = password
        @host = host
        @port = port
        @database = database

        @template = if type == :mysql
                      ERB.new(File.read(File.join(WordpressDeploy::TEMPLATE_PATH, 'mysql-opts.erb')))
                    else
                      ERB.new(File.read(File.join(WordpressDeploy::TEMPLATE_PATH, 'mysqldump-opts.erb')))
                    end
        @option_file = Tempfile.new(%w(mysql-opts .conf))
        @option_file.write(@template.result(binding))
        @option_file.flush
      end

      ##
      #
      def path
        @option_file.path
      end
    end
  end
end
