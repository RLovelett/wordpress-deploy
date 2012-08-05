require "thor"

module WordpressDeploy
  ##
  # WordpressDeploy's internal paths
  #
  LIBRARY_PATH            = File.join(File.dirname(__FILE__), 'wordpress_deploy')
  CLI_PATH                = File.join(LIBRARY_PATH, 'cli')
  WORDPRESS_PATH          = File.join(LIBRARY_PATH, 'wordpress')
  TRANSFER_PROTOCOLS_PATH = File.join(LIBRARY_PATH, 'transfer_protocols')
  DATABASE_PATH           = File.join(LIBRARY_PATH, 'database')

  module Cli
    autoload :Utility, File.join(CLI_PATH, 'utility')
  end

  module Wordpress
    autoload :Configuration, File.join(WORDPRESS_PATH, 'configuration')
  end

  module TransferProtocols
    autoload :Ftp, File.join(TRANSFER_PROTOCOLS_PATH, 'ftp')
  end

  module Database
    autoload :MySql, File.join(DATABASE_PATH, 'mysql')
  end

  %w{version logger errors environment}.each do |klass|
    require File.join(LIBRARY_PATH, klass)
  end
end
