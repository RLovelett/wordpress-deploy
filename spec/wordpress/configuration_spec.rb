require 'spec_helper'

describe WordpressDeploy::Wordpress::Configuration do
  it { should respond_to :name }
  it { should respond_to :name= }
  it { should respond_to :available_names }
  it { should respond_to :names }
  it { should respond_to :template }
  it { should respond_to :output }
  it { should respond_to :save! }
  it { should respond_to :db_port }
  it { should respond_to :db_port? }
  it { should respond_to :db_hostname }
  it { should respond_to :db_socket }
  it { should respond_to :db_socket? }

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

  its(:names) { should have(5).strings }
  its(:names) { should include "development" }
  its(:names) { should include "production" }
  its(:names) { should include "red" }
  its(:names) { should include "green" }
  its(:names) { should include "blue" }
  its(:available_names) { should have(5).strings }
  its(:available_names) { should include "development" }
  its(:available_names) { should include "production" }
  its(:available_names) { should include "red" }
  its(:available_names) { should include "green" }
  its(:available_names) { should include "blue" }

  it "should allow creation of new configuration by name" do
    config = WordpressDeploy::Wordpress::Configuration.new "red"
    config.name.should eq "red"
  end

  it "should only allow configuration names found in the yaml file" do
    ["production", "development", "red", "green", "blue"].each do |name|
      subject.name = name
      subject.name.should eq name
    end
    [:production, nil].each do |name|
      subject.name = name
      subject.name.should_not eq name
    end
  end

  shared_examples "named configuration" do
    before(:each) { subject.name = name }
    its(:name)             { should eq name }
    its(:DB_NAME)          { should eq db_name }
    its(:DB_USER)          { should eq db_user }
    its(:DB_PASSWORD)      { should eq db_password }
    its(:DB_HOST)          { should eq db_host }
    its(:DB_CHARSET)       { should eq db_charset }
    its(:DB_COLLATE)       { should eq db_collate }
    its(:WPLANG)           { should eq wplang }
    its(:WP_DEBUG)         { should be_true }
    its(:AUTH_KEY)         { should be_salt }
    its(:SECURE_AUTH_KEY)  { should be_salt }
    its(:LOGGED_IN_KEY)    { should be_salt }
    its(:NONCE_KEY)        { should be_salt }
    its(:AUTH_SALT)        { should be_salt }
    its(:SECURE_AUTH_SALT) { should be_salt }
    its(:LOGGED_IN_SALT)   { should be_salt }
    its(:NONCE_SALT)       { should be_salt }
    its(:db_port)          { should eq port_num }
    its(:db_port?)         { should eq has_port }
    its(:db_hostname)      { should eq host }
    its(:db_socket)        { should eq socket }
    its(:db_socket?)       { should eq has_socket }
  end

  context "development" do
    it_should_behave_like "named configuration" do
      let(:name)             { "development" }
      let(:db_name)          { "developer_database_name" }
      let(:db_user)          { "root" }
      let(:db_password)      { "q9&hu6Re_*dReWr_GAba_2wr89#2Ra8$" }
      let(:db_host)          { "localhost" }
      let(:db_charset)       { "utf8" }
      let(:db_collate)       { "" }
      let(:wplang)           { "" }
      let(:port_num)         { 3306 }
      let(:has_port)         { false }
      let(:host)             { "localhost" }
      let(:socket)           { "" }
      let(:has_socket)       { false }
    end
  end

  context "production" do
    it_should_behave_like "named configuration" do
      let(:name) { 'production' }
      let(:db_name)          { "production_database_name" }
      let(:db_user)          { "some_user" }
      let(:db_password)      { "trecuwawraJaZe6P@kucraDrachustUq" }
      let(:db_host)          { "abbott.biz:6654" }
      let(:db_charset)       { "utf8" }
      let(:db_collate)       { "" }
      let(:wplang)           { "" }
      let(:port_num)         { 6654 }
      let(:has_port)         { true }
      let(:host)             { "abbott.biz" }
      let(:socket)           { "" }
      let(:has_socket)       { false }
    end
  end

  context "red" do
    it_should_behave_like "named configuration" do
      let(:name) { 'red' }
      let(:db_name)          { "red" }
      let(:db_user)          { "red_user" }
      let(:db_password)      { "Bun__huPEMeBreM6tebRAp@eguzuQExe" }
      let(:db_host)          { "hanerutherford.biz" }
      let(:db_charset)       { "utf8" }
      let(:db_collate)       { "" }
      let(:wplang)           { "" }
      let(:port_num)         { 3306 }
      let(:has_port)         { false }
      let(:host)             { "hanerutherford.biz" }
      let(:socket)           { "" }
      let(:has_socket)       { false }
    end
  end
  
  context "green" do
    it_should_behave_like "named configuration" do
      let(:name) { 'green' }
      let(:db_name)          { "green" }
      let(:db_user)          { "domenick.dare" }
      let(:db_password)      { "Daw&HEWuzaz6sa&epHech_spAKucHaTH" }
      let(:db_host)          { "yundt.org" }
      let(:db_charset)       { "utf8" }
      let(:db_collate)       { "" }
      let(:wplang)           { "" }
      let(:port_num)         { 3306 }
      let(:has_port)         { false }
      let(:host)             { "yundt.org" }
      let(:socket)           { "" }
      let(:has_socket)       { false }
    end
  end

  context "blue" do
    it_should_behave_like "named configuration" do
      let(:name) { 'blue' }
      let(:db_name)          { "blue" }
      let(:db_user)          { "harrison" }
      let(:db_password)      { "w5@reba?9?pepuk7w9a#H86ustaGawE!" }
      let(:db_host)          { "torphagenes.com:/tmp/mysql5.sock" }
      let(:db_charset)       { "utf8" }
      let(:db_collate)       { "" }
      let(:wplang)           { "" }
      let(:port_num)         { 3306 }
      let(:has_port)         { false }
      let(:host)             { "torphagenes.com" }
      let(:socket)           { "/tmp/mysql5.sock" }
      let(:has_socket)       { true }
    end
  end

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
