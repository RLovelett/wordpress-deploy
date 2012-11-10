require 'spec_helper'

describe WordpressDeploy::Cli::Utility do
  before(:each) do
    # Make sure the logger is defined
    WordpressDeploy::Logger.should_receive(:verbose=)

    # Make sure the options are defined
    WordpressDeploy::Config.should_receive(:set_options)

    # Make sure the environments are loaded
    WordpressDeploy::Environments.should_receive(:load)
  end

  it "should generate the wp-config.php file for a real environment" do
    # Get the Environment instance
    stub = double("Environment")
    WordpressDeploy::Environments.should_receive(:find).with(:development).and_return(stub)

    # Because the find method was stubbed just make sure the
    # Environment#save_wp_config is called on the stubbed
    # object
    stub.should_receive(:save_wp_config)

    # Execute the command
    args = ["config", "development"]
    arg, options = WordpressDeploy::Cli::Utility.start(args)
  end

  it "should deploy the configured environments" do
    # Get the Environment instance
    from = double("Environment")
    to   = double("Environment")
    WordpressDeploy::Environments.should_receive(:find).once.with(:development).and_return(from)
    WordpressDeploy::Environments.should_receive(:find).once.with(:production).and_return(to)

    to.should_receive(:save_wp_config)
    to.stub_chain(:transfer, :transmit!)
    from.stub_chain(:database, :save!)
    from.stub_chain(:database, :send!).with(to)
    from.stub_chain(:database, :migrate!).with(to)

    # Execute the command
    args = ["deploy", "development", "production"]
    arg, options = WordpressDeploy::Cli::Utility.start(args)
  end

end
