require "thor"
require "open3"
require "fileutils"
require "yaml"

module WordpressDeploy
  ##
  # WordpressDeploy's internal paths
  #
  LIBRARY_PATH    = File.join(File.dirname(__FILE__), 'wordpress_deploy')
  CLI_PATH        = File.join(LIBRARY_PATH, 'cli')
  WORDPRESS_PATH  = File.join(LIBRARY_PATH, 'wordpress')
  STORAGE_PATH    = File.join(LIBRARY_PATH, 'storage')
  DATABASE_PATH   = File.join(LIBRARY_PATH, 'database')

  module Cli
    autoload :Helpers, File.join(CLI_PATH, 'helpers')
    autoload :Utility, File.join(CLI_PATH, 'utility')
  end

  module Wordpress
    autoload :Salts, File.join(WORDPRESS_PATH, 'salts')
  end

  module Storage
    autoload :Ftp,   File.join(STORAGE_PATH, 'ftp')
    autoload :Local, File.join(STORAGE_PATH, 'local')
  end

  module Database
    autoload :MySql, File.join(DATABASE_PATH, 'mysql')
  end

  %w{version logger errors config environments environment}.each do |klass|
    require File.join(LIBRARY_PATH, klass)
  end
end
