require 'spec_helper'

include WordpressDeploy::Database
include WordpressDeploy::Wordpress

describe WordpressDeploy::Database::MySql do

  let(:mysql)     { "/path/to/mysql" }
  let(:mysqldump) { "/path/to/mysqldump" }
  let(:environment) do
    WordpressDeploy::Database::Environment.new do
      name "production_database_name"
      user "some_user"
      password "trecuwawraJaZe6P@kucraDrachustUq"
      host "abbott.biz:6654"
      charset "utf8"
      collate ""
    end
  end

  subject { WordpressDeploy::Database::MySql.new(environment) }


  context "mixins inherited from WordpressDeploy::Cli::Helpers" do
    it { should respond_to :run }
    it { should respond_to :utility }
    it { should respond_to :command_name }
  end

  it { should respond_to :connection? }
  it { should respond_to :save! }
  it { should respond_to :send! }
  it { should respond_to :migrate! }

  describe "#connection?" do
    it "returns false if there are any exceptions"
    it "returns the value of Sequel::Database#test_connection otherwise"
  end

  describe "#save!" do
    let(:mysql_cmd) { "#{mysqldump} -P \"6654\" -h \"abbott.biz\" -u \"some_user\" -p\"trecuwawraJaZe6P@kucraDrachustUq\" -B \"production_database_name\"" }

    before(:each) do
      subject.should_receive(:utility).with("mysqldump").and_return(mysqldump)
      subject.should_receive(:run).with(mysql_cmd).and_return("STDOUT from run")
    end

    it "calls mysqldump command with the correct arguments" do
      subject.save!.should be_true
    end

    it "saves STDOUT from mysqldump to a file" do
      # Stub file behavior;
      # expect to receive a call to new, write, and close
      file = double("file")
      File.should_receive(:new).with(/production_database_name.sql$/, 'w').and_return(file)
      file.should_receive(:write).with("STDOUT from run")
      file.should_receive(:close)

      subject.save!.should be_true
    end
  end

  describe "#send!" do
    it "checks if there is a database dump for the from environment"
    it "creates a temporary to environment file"
    it "writes the from environment database to the temporary file"
    it "changes the database name in the temporary file"
    it "creates the mysqload command"
    it "executes the command"
  end

  describe "#migrate!" do
    it "checks there is a valid connection"
    it "gets list of tables on the destination database"
    it "gets list of columns for each table"
    it "queries each column for each table for rows that need updating"
    it "builds a transaction containing many queries"
    it "executes all updates as one transaction"
  end

end
