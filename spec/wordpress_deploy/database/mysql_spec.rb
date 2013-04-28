require 'spec_helper'

include WordpressDeploy::Database
include WordpressDeploy::Wordpress

describe MySql do

  let(:mysql)     { "/path/to/mysql" }
  let(:mysqldump) { "/path/to/mysqldump" }

  it { should respond_to :run }
  it { should respond_to :utility }
  it { should respond_to :command_name }
  it { should respond_to :file }
  it { should respond_to :save! }
  it { should respond_to :send! }
  it { should respond_to :migrate! }

  shared_examples "the environment is" do |env_name|
    before(:all) { WordpressDeploy::Environments.load }
    subject { WordpressDeploy::Environments.find(env_name).database }
    context "#{env_name}" do
      its(:name)     { should eq expected_name }
      its(:user)     { should eq expected_user }
      its(:password) { should eq expected_password }
      its(:host)     { should eq expected_host }
      its(:wp_host)  { should eq expected_wp_host }
      its(:charset)  { should eq expected_charset }
      its(:collate)  { should eq expected_collate }
      its(:port)     { should eq expected_port }
      its(:socket)   { should eq expected_socket }
      its(:port?)    { should eq has_port }
      its(:socket?)  { should eq has_socket }
      its(:file)     { should =~ /#{expected_name}.sql$/ }
    end
  end

  it_should_behave_like "the environment is", :development do
    let(:expected_name)          { "developer_database_name" }
    let(:expected_user)          { "root" }
    let(:expected_password)      { "q9&hu6Re_*dReWr_GAba_2wr89#2Ra8$" }
    let(:expected_host)          { "localhost" }
    let(:expected_wp_host)       { "localhost" }
    let(:expected_charset)       { "utf8" }
    let(:expected_collate)       { "" }
    let(:expected_port)          { 3306 }
    let(:expected_socket)        { "" }
    let(:has_port)               { false }
    let(:has_socket)             { false }

    let(:expected_args) { "-P \"3306\" -h \"localhost\" -u \"root\" -p\"q9&hu6Re_*dReWr_GAba_2wr89#2Ra8$\" -B \"developer_database_name\"" }
  end

  it_should_behave_like "the environment is", :production do
    let(:expected_name)          { "production_database_name" }
    let(:expected_user)          { "some_user" }
    let(:expected_password)      { "trecuwawraJaZe6P@kucraDrachustUq" }
    let(:expected_host)          { "abbott.biz" }
    let(:expected_wp_host)       { "abbott.biz:6654" }
    let(:expected_charset)       { "utf8" }
    let(:expected_collate)       { "" }
    let(:expected_port)          { 6654 }
    let(:expected_socket)        { "" }
    let(:has_port)               { true }
    let(:has_socket)             { false }

    let(:expected_args) { "-P \"6654\" -h \"abbott.biz\" -u \"some_user\" -p\"trecuwawraJaZe6P@kucraDrachustUq\" -B \"production_database_name\"" }
  end

  it_should_behave_like "the environment is", :red do
    let(:expected_name)          { "red" }
    let(:expected_user)          { "red_user" }
    let(:expected_password)      { "Bun__huPEMeBreM6tebRAp@eguzuQExe" }
    let(:expected_host)          { "hanerutherford.biz" }
    let(:expected_wp_host)       { "hanerutherford.biz" }
    let(:expected_charset)       { "utf8" }
    let(:expected_collate)       { "" }
    let(:expected_port)          { 3306 }
    let(:expected_socket)        { "" }
    let(:has_port)               { false }
    let(:has_socket)             { false }

    let(:expected_args) { "-P \"3306\" -h \"hanerutherford.biz\" -u \"red_user\" -p\"Bun__huPEMeBreM6tebRAp@eguzuQExe\" -B \"red\"" }
  end

  it_should_behave_like "the environment is", :green do
    let(:expected_name)          { "green" }
    let(:expected_user)          { "domenick.dare" }
    let(:expected_password)      { "Daw&HEWuzaz6sa&epHech_spAKucHaTH" }
    let(:expected_host)          { "yundt.org" }
    let(:expected_wp_host)       { "yundt.org" }
    let(:expected_charset)       { "utf8" }
    let(:expected_collate)       { "" }
    let(:expected_port)          { 3306 }
    let(:expected_socket)        { "" }
    let(:has_port)               { false }
    let(:has_socket)             { false }

    let(:expected_args) { "-P \"3306\" -h \"yundt.org\" -u \"domenick.dare\" -p\"Daw&HEWuzaz6sa&epHech_spAKucHaTH\" -B \"green\"" }
  end

  it_should_behave_like "the environment is", :blue do
    let(:expected_name)          { "blue" }
    let(:expected_user)          { "harrison" }
    let(:expected_password)      { "w5@reba?9?pepuk7w9a#H86ustaGawE!" }
    let(:expected_host)          { "torphagenes.com" }
    let(:expected_wp_host)       { "torphagenes.com:/tmp/mysql5.sock" }
    let(:expected_charset)       { "utf8" }
    let(:expected_collate)       { "" }
    let(:expected_port)          { 3306 }
    let(:expected_socket)        { "/tmp/mysql5.sock" }
    let(:has_port)               { false }
    let(:has_socket)             { true }

    let(:expected_args) { "-P \"3306\" -h \"torphagenes.com\" -u \"harrison\" -p\"w5@reba?9?pepuk7w9a#H86ustaGawE!\" -B \"blue\"" }
  end

  context "dump the configuration's database to the local filesystem" do
    let(:mysql_cmd) { "#{mysqldump} -P \"6654\" -h \"abbott.biz\" -u \"some_user\" -p\"trecuwawraJaZe6P@kucraDrachustUq\" -B \"production_database_name\"" }

    before(:each) do
      @mysql = WordpressDeploy::Environments.production.database
      @mysql.should_receive(:utility).with("mysqldump").and_return(mysqldump)
      @mysql.should_receive(:run).and_return("STDOUT from run")
    end

    it "should call the mysqldump command with the correct arguments" do
      @mysql.save!
    end

    it "should then save the output from STDOUT to a file" do
      # Stub file behavior;
      # expect to receive a call to new, write, and close
      file = double("file")
      File.should_receive(:new).with(/production_database_name.sql$/, 'w').and_return(file)
      file.should_receive(:write).with("STDOUT from run")
      file.should_receive(:close)

      @mysql.save!
    end
  end

  context "send a dumped configuration's database to a remote database" do

  end

end
