require 'rubygems'
require 'bundler/setup'

require 'wordpress_deploy'

def data_dir
  File.join(File.dirname(__FILE__), "data")
end

RSpec.configure do |config|
  # Optional configuration here

  # Reset the environment for each spec that is run
  config.before(:each) do
    WordpressDeploy::Environment.root_dir    = data_dir
    WordpressDeploy::Environment.wp_dir      = "."
    WordpressDeploy::Environment.config_dir  = "."
    WordpressDeploy::Environment.logging     = false
    WordpressDeploy::Environment.environment = "development"
  end

  # Clean-up log files after each spec
  config.after(:all) do
    WordpressDeploy::Environment.clean!
  end

end

RSpec::Matchers.define :be_salt do |expected|
  match do |actual|
    actual.instance_of? String
    actual.to_s.size === 64
  end
end
