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
    before(:each) do
      # Prevent actual database calls from occurring
      @database = double("Sequel::Database")
      Sequel.stub(:mysql).and_return(@database)

      @dataset = double("Sequel::Dataset")
    end

    let(:find)    { "http://#{Faker::Internet.domain_name}" }
    let(:replace) { "http://#{Faker::Internet.domain_name}" }

    context "without a valid database connection" do
      before(:each) { subject.should_receive(:connection?).and_return(false) }
      it { expect { subject.migrate!(find, replace) }.to raise_error }
    end

    it "gets list of tables on the destination database" do
      columns = [[:id,
                 {:type=>:integer,
                  :primary_key=>true,
                  :default=>"nextval('artist_id_seq'::regclass)",
                  :ruby_default=>nil,
                  :db_type=>"integer",
                  :allow_null=>false}],
                [:name,
                 {:type=>:string,
                  :primary_key=>false,
                  :default=>nil,
                  :ruby_default=>nil,
                  :db_type=>"text",
                  :allow_null=>false}]]
      subject.should_receive(:connection?).and_return(true)
      @database.should_receive(:tables).and_return([:table_1, :table_2])
      @database.should_receive(:schema).once.with(:table_1).ordered.and_return(columns)
      @database.should_receive(:schema).once.with(:table_2).ordered.and_return(columns)
      @database.stub_chain(:select, :from, :where).with(kind_of(Sequel::SQL::BooleanExpression)).and_return(@dataset)
      @database.stub_chain(:select, :from, :where).with(kind_of(Sequel::SQL::BooleanExpression)).and_return(@dataset)
      @database.should_receive(:transaction).twice

      @dataset.should_receive(:select_sql).twice.and_return("SELECT * blah")
      @dataset.should_receive(:each).twice.and_yield({id: 1, name: ""})

      expect { subject.migrate!(find, replace) }.to_not raise_error
    end

    it "gets list of columns for each table"
    it "queries each column for each table for rows that need updating"
    it "builds a transaction containing many queries"
    it "executes all updates as one transaction"
    it "logs errors if errors are created"
  end

end
