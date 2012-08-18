require "thor"
require "open3"
require "fileutils"
require "yaml"

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
    autoload :Helpers, File.join(CLI_PATH, 'helpers')
    autoload :Utility, File.join(CLI_PATH, 'utility')
  end

  module Wordpress
    autoload :Salts, ::File.join(WORDPRESS_PATH, 'salts')
  end

  module TransferProtocols
    autoload :Ftp, File.join(TRANSFER_PROTOCOLS_PATH, 'ftp')
  end

  module Database
    autoload :MySql, File.join(DATABASE_PATH, 'mysql')
  end

  %w{version logger errors config}.each do |klass|
    require File.join(LIBRARY_PATH, klass)
  end
end
