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

  it_should_behave_like "Wordpress::ConfigurationFile mixin"

  shared_examples "WordpressDeploy::Cli::Helpers mixin" do
    before(:each) do
      subject.name = name
      subject.stub(:utility).with("mysqldump").and_return(mysqldump)
    end
    its(:mysqldump) { should eq "#{mysqldump} #{expected_args}" }
    its(:file)      { should =~ /#{name}.sql$/ }
  end

  context "when configuration is 'development'" do
    it_should_behave_like "WordpressDeploy::Cli::Helpers mixin" do
      let(:name) { "development" }
      let(:expected_args) { "-P \"3306\" -h \"localhost\" -u \"root\" -p\"q9&hu6Re_*dReWr_GAba_2wr89#2Ra8$\" -B \"developer_database_name\"" }
    end
  end

  context "when configuration is 'production'" do
    it_should_behave_like "WordpressDeploy::Cli::Helpers mixin" do
      let(:name) { "production" }
      let(:expected_args) { "-P \"6654\" -h \"abbott.biz\" -u \"some_user\" -p\"trecuwawraJaZe6P@kucraDrachustUq\" -B \"production_database_name\"" }
    end
  end

  context "when configuration is 'red'" do
    it_should_behave_like "WordpressDeploy::Cli::Helpers mixin" do
      let(:name) { "red" }
      let(:expected_args) { "-P \"3306\" -h \"hanerutherford.biz\" -u \"red_user\" -p\"Bun__huPEMeBreM6tebRAp@eguzuQExe\" -B \"red\"" }
    end
  end

  context "when configuration is 'green'" do
    it_should_behave_like "WordpressDeploy::Cli::Helpers mixin" do
      let(:name) { "green" }
      let(:expected_args) { "-P \"3306\" -h \"yundt.org\" -u \"domenick.dare\" -p\"Daw&HEWuzaz6sa&epHech_spAKucHaTH\" -B \"green\"" }
    end
  end

  context "when configuration is 'blue'" do
    it_should_behave_like "WordpressDeploy::Cli::Helpers mixin" do
      let(:name) { "blue" }
      let(:expected_args) { "-P \"3306\" -h \"torphagenes.com\" -u \"harrison\" -p\"w5@reba?9?pepuk7w9a#H86ustaGawE!\" -B \"blue\"" }
    end
  end

  context "dump the configuration's database to the local filesystem" do
    let(:mysql_cmd) { "#{mysqldump} -P \"6654\" -h \"abbott.biz\" -u \"some_user\" -p\"trecuwawraJaZe6P@kucraDrachustUq\" -B \"production_database_name\"" }

    before(:each) do
      @mysql = MySql.new "production"
      @mysql.should_receive(:utility).with("mysqldump").and_return(mysqldump)
      @mysql.should_receive(:run).with(mysql_cmd).and_return("STDOUT from run")
    end

    it "should call the mysqldump command with the correct arguments" do
      @mysql.save!
    end

    it "should then save the output from STDOUT to a file" do
      # Stub file behavior;
      # expect to receive a call to new, write, and close
      file = double("file")
      File.should_receive(:new).with(/production.sql$/, 'w').and_return(file)
      file.should_receive(:write).with("STDOUT from run")
      file.should_receive(:close)

      @mysql.save!
    end
  end

  context "send a dumped configuration's database to a remote database" do

  end

end
