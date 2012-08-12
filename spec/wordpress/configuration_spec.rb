require 'spec_helper'

describe WordpressDeploy::Wordpress::Configuration do

  it { should respond_to :names }
  it { should respond_to :template }
  it { should respond_to :output }
  it { should respond_to :save! }

  its(:template) { should =~ /wp-config-sample.php$/ }
  its(:output)   { should =~ /wp-config.php$/ }

  it_should_behave_like "Wordpress::ConfigurationFile mixin"

  describe "saving configuration" do
    it "should create a file if it does not exist" do
      # Remove the file (even if it exists)
      FileUtils.rm subject.output if File.exists? subject.output

      # Try saving it
      subject.save!

      # Check that it now exists
      File.exists?(subject.output).should be_true
    end

    it "should be calling all of the configuration properties" do
      WordpressDeploy::Wordpress::Configuration::WP_CONFIGURATION_ALL.each do |attr|
        subject.should_receive(attr).exactly(1).times
      end
      subject.should_receive(:define).exactly(WordpressDeploy::Wordpress::Configuration::WP_CONFIGURATION_ALL.count).times
      subject.save!
    end
  end
end
