require 'spec_helper'

describe WordpressDeploy::Wordpress::Configuration do
  context "static" do
    subject { WordpressDeploy::Wordpress::Configuration }
    it { should respond_to :salt }
    its(:salt) { should be_salt }
  end

  context "instance" do
    subject { WordpressDeploy::Wordpress::Configuration.new }

    it { should respond_to :template }
    it { should respond_to :output }
    it { should respond_to :save! }

    it { should respond_to :DB_NAME }
    it { should respond_to :DB_USER }
    it { should respond_to :DB_PASSWORD }
    it { should respond_to :DB_HOST }
    it { should respond_to :DB_CHARSET }
    it { should respond_to :DB_COLLATE }
    it { should respond_to :WPLANG }
    it { should respond_to :WP_DEBUG }
    it { should respond_to :AUTH_KEY }
    it { should respond_to :SECURE_AUTH_KEY }
    it { should respond_to :LOGGED_IN_KEY }
    it { should respond_to :NONCE_KEY }
    it { should respond_to :AUTH_SALT }
    it { should respond_to :SECURE_AUTH_SALT }
    it { should respond_to :LOGGED_IN_SALT }
    it { should respond_to :NONCE_SALT }

    its(:template) { should =~ /wp-config-sample.php$/ }
    its(:output)   { should =~ /wp-config.php$/ }

    its(:DB_NAME)          { should eq "developer_database_name" }
    its(:DB_USER)          { should eq "root" }
    its(:DB_PASSWORD)      { should eq "temp" }
    its(:DB_HOST)          { should eq "localhost" }
    its(:DB_CHARSET)       { should eq "utf8" }
    its(:DB_COLLATE)       { should eq "" }
    its(:WPLANG)           { should eq "" }
    its(:WP_DEBUG)         { should be_true }
    its(:AUTH_KEY)         { should be_salt }
    its(:SECURE_AUTH_KEY)  { should be_salt }
    its(:LOGGED_IN_KEY)    { should be_salt }
    its(:NONCE_KEY)        { should be_salt }
    its(:AUTH_SALT)        { should be_salt }
    its(:SECURE_AUTH_SALT) { should be_salt }
    its(:LOGGED_IN_SALT)   { should be_salt }
    its(:NONCE_SALT)       { should be_salt }

    describe "saving configuration" do
      it "should create a file if it does not exist" do
        # Remove the file (even if it exists)
        FileUtils.rm subject.output

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
end
