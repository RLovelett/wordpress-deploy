require 'rubygems'
require 'bundler/setup'
require 'fake_ftp'
require 'fakefs/safe'
require 'fakefs/spec_helpers'
require 'faker'

require 'wordpress_deploy'

def data_dir
  File.join(File.dirname(__FILE__), "data")
end

# Set shell to basic
$0 = "thor"
$thor_runner = true
ARGV.clear
Thor::Base.shell = Thor::Shell::Basic

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.include FakeFS::SpecHelpers, fakefs: true

  # Reset the environment for each spec that is run
  config.before(:each) do
    WordpressDeploy::Config.root_dir    = data_dir
    WordpressDeploy::Config.wp_dir      = "."
    WordpressDeploy::Config.config_dir  = "."
    WordpressDeploy::Config.sql_dir     = "."
    WordpressDeploy::Config.logging     = false
  end

  config.before(:all) do
    WordpressDeploy::Environments.load
  end

  # Clean-up log files after each spec
  config.after(:all) do
    WordpressDeploy::Config.clean!
  end

end

RSpec::Matchers.define :be_salt do |expected|
  match do |actual|
    actual.instance_of? String
    actual.to_s.size === 64
  end
end
