require "thor"
require "open3"
require "fileutils"
require "yaml"

class Hash
  def find_and_replace!(find, replace)
    self.each do |key, value|
      if value.instance_of? Hash
        value.find_and_replace! find, replace
      else
        if value.instance_of? String
          value.gsub!(/#{find}/, replace)
        elsif value.instance_of? Array
          value.map! do |child_val|
            if value.instance_of? String
              value.gsub!(/#{find}/, replace)
            elsif value.instance_of? Hash
              value.find_and_replace! find, replace
            end
          end
        end
      end
    end
  end
end

module WordpressDeploy
  ##
  # WordpressDeploy's internal paths
  #
  LIBRARY_PATH    = File.join(File.dirname(__FILE__), 'wordpress_deploy')
  TEMPLATE_PATH   = File.join(File.dirname(__FILE__), '..', 'templates')
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
