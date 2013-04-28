require "thor"
require "open3"
require "fileutils"
require "yaml"

class Hash

  def find_and_replace!(find, replace)
    RecursiveReplace.find_and_replace!(find, replace, self) 
  end

end

class RecursiveReplace

  def self.find_and_replace!(find, replace, obj)
    m = "find_and_replace_#{obj.class}!"
    send(m, find, replace, obj) if respond_to? m, true
  end

  private

  def self.find_and_replace_Hash!(find, replace, hash)
    hash.each { |k,v| find_and_replace!(find, replace, v) }
  end

  def self.find_and_replace_Array!(find, replace, arr)
    arr.each { |x| find_and_replace!(find, replace, x) }
  end

  def self.find_and_replace_String!(find, replace, str)
    str.gsub!(/#{find}/, replace)
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
    autoload :MySql,      File.join(DATABASE_PATH, 'mysql')
    autoload :OptionFile, File.join(DATABASE_PATH, 'option_file')
  end

  %w{version logger errors config environments environment}.each do |klass|
    require File.join(LIBRARY_PATH, klass)
  end
end
