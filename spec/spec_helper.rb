require 'rubygems'
require 'bundler/setup'

require 'wordpress_deploy'

def data_dir
  File.join(File.dirname(__FILE__), "data")
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Reset the environment for each spec that is run
  config.before(:each) do
    WordpressDeploy::Environment.root_dir    = data_dir
    WordpressDeploy::Environment.wp_dir      = "."
    WordpressDeploy::Environment.config_dir  = "."
    WordpressDeploy::Environment.logging     = false
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
