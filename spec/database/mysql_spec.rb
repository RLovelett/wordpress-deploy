require 'spec_helper'

include WordpressDeploy::Database
include WordpressDeploy::Wordpress

describe MySql do

  let(:mysql)     { "/path/to/mysql" }
  let(:mysqldump) { "/path/to/mysqldump" }

  it { should respond_to :run }
  it { should respond_to :utility }
  it { should respond_to :command_name }
  it { should respond_to :mysqldump }
  it { should respond_to :configuration }
  it { should respond_to :configuration= }

  shared_examples "command based on configuration" do
    before(:each) do
      subject.configuration = WordpressDeploy::Wordpress::Configuration.new name
      subject.stub(:utility).with("mysqldump").and_return(mysqldump)
    end
    its(:arguments) { should eq expected_args }
    its(:mysqldump) { should eq "#{mysqldump} #{expected_args}" }
  end

  context "when configuration is 'development'" do
    it_should_behave_like "command based on configuration" do
      let(:name) { "development" }
      let(:expected_args) { "-P \"3306\" -h \"localhost\" -u \"root\" -pq9&hu6Re_*dReWr_GAba_2wr89#2Ra8$ -B \"developer_database_name\"" }
    end
  end

  context "when configuration is 'production'" do
    it_should_behave_like "command based on configuration" do
      let(:name) { "production" }
      let(:expected_args) { "-P \"6654\" -h \"abbott.biz\" -u \"some_user\" -ptrecuwawraJaZe6P@kucraDrachustUq -B \"production_database_name\"" }
    end
  end

  context "when configuration is 'red'" do
    it_should_behave_like "command based on configuration" do
      let(:name) { "red" }
      let(:expected_args) { "-P \"3306\" -h \"hanerutherford.biz\" -u \"red_user\" -pBun__huPEMeBreM6tebRAp@eguzuQExe -B \"red\"" }
    end
  end

  context "when configuration is 'green'" do
    it_should_behave_like "command based on configuration" do
      let(:name) { "green" }
      let(:expected_args) { "-P \"3306\" -h \"yundt.org\" -u \"domenick.dare\" -pDaw&HEWuzaz6sa&epHech_spAKucHaTH -B \"green\"" }
    end
  end

  context "when configuration is 'blue'" do
    it_should_behave_like "command based on configuration" do
      let(:name) { "blue" }
      let(:expected_args) { "-P \"3306\" -h \"torphagenes.com\" -u \"harrison\" -pw5@reba?9?pepuk7w9a#H86ustaGawE! -B \"blue\"" }
    end
  end

  context "find commands" do
    it "should raise Errors::Cli::UtilityNotFoundError if no command given" do
      expect{subject.utility ""}.to raise_error(WordpressDeploy::Errors::Cli::UtilityNotFoundError)
    end
    it "should raise Errors::Cli::UtilityNotFoundError if command not found" do
      expect{subject.utility "missing_system_command"}.to raise_error(WordpressDeploy::Errors::Cli::UtilityNotFoundError)
    end
    it "mysql" do
      stdin    = Object.new
      stdin.stub(:close)

      stdout   = Object.new.stub(:read).and_return("")
      stdout.stub(:read).and_return(mysql)

      stderr   = Object.new.stub(:read).and_return("")
      stderr.stub(:read).and_return("")

      wait_thr = Object.new
      wait_thr.stub(:value).and_return($?)

      Open3.should_receive(:popen3).exactly(1).times.and_yield(stdin, stdout, stderr, wait_thr)

      subject.utility("mysql").should eq mysql
      WordpressDeploy::Database::MySql::UTILITY["mysql"].should eq mysql
    end
  end

  it "should parse out the command name" do
    subject.command_name("#{mysqldump} -P \"3306\" -h \"NOT_localhost\" -u \"root\" -ptemp -B \"developer_database_name\"").should eq "mysqldump"
  end

end
