require 'spec_helper'

include WordpressDeploy

describe WordpressDeploy::TransferProtocols::Ftp do
  before(:each) do
    # None of the methods that follow are testing
    # the Net::FTP object actions; therefore they
    # can be stubbed out
    @ftp = double("ftp")
    [:connect, :login, :passive=].each do |methods|
      @ftp.stub(methods).with(any_args)
    end
    Net::FTP.stub(:new).and_return(@ftp)
  end

  it { should respond_to :name }
  it { should respond_to :name= }
  it { should respond_to :available_names }
  it { should respond_to :names }
  it { should respond_to :port }
  it { should respond_to :port? }
  it { should respond_to :host }
  it { should respond_to :configuration }
  it { should respond_to :configuration= }

  it { should respond_to :FTP_USER }
  it { should respond_to :FTP_PASSWORD }
  it { should respond_to :FTP_HOST }
  it { should respond_to :FTP_DIR }

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
    ftp = WordpressDeploy::TransferProtocols::Ftp.new "red"
    ftp.name.should eq "red"
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

  shared_examples "ftp named configuration" do
    before(:each) { subject.name = name }
    its(:name)         { should eq name }
    its(:FTP_USER)     { should eq ftp_user }
    its(:FTP_PASSWORD) { should eq ftp_password }
    its(:FTP_HOST)     { should eq ftp_host }
    its(:FTP_DIR)      { should eq ftp_dir_raw }
    its(:local_path)   { should eq Environment.wp_dir }
    its(:remote_path)  { should eq ftp_dir }
    its(:username)     { should eq ftp_user }
    its(:password)     { should eq ftp_password }
    its(:host)         { should eq host }
    its(:port)         { should eq port }
    its(:port?)        { should eq has_port }
  end

  context "development" do
    it_should_behave_like "ftp named configuration" do
      let(:name)         { "development" }
      let(:ftp_user)     { "root" }
      let(:ftp_password) { "q9&hu6Re_*dReWr_GAba_2wr89#2Ra8$" }
      let(:ftp_host)     { "localhost" }
      let(:ftp_dir_raw)  { "/wordpress" }
      let(:ftp_dir)      { "/wordpress" }
      let(:host)         { "localhost" }
      let(:port)         { 21 }
      let(:has_port)     { false }
    end
  end

  context "production" do
    it_should_behave_like "ftp named configuration" do
      let(:name)         { "production" }
      let(:ftp_user)     { "some_user" }
      let(:ftp_password) { "trecuwawraJaZe6P@kucraDrachustUq" }
      let(:ftp_host)     { "ftp.abbott.biz:6654" }
      let(:ftp_dir_raw)  { nil }
      let(:ftp_dir)      { "/" }
      let(:host)         { "ftp.abbott.biz" }
      let(:port)         { 6654 }
      let(:has_port)     { true }
    end
  end

  context "red" do
    it_should_behave_like "ftp named configuration" do
      let(:name)         { "red" }
      let(:ftp_user)     { "red_user" }
      let(:ftp_password) { "Bun__huPEMeBreM6tebRAp@eguzuQExe" }
      let(:ftp_host)     { "ftp.hanerutherford.biz" }
      let(:ftp_dir_raw)  { "/html" }
      let(:ftp_dir)      { "/html" }
      let(:host)         { "ftp.hanerutherford.biz" }
      let(:port)         { 21 }
      let(:has_port)     { false }
    end
  end

  context "green" do
    it_should_behave_like "ftp named configuration" do
      let(:name)         { "green" }
      let(:ftp_user)     { "domenick.dare" }
      let(:ftp_password) { "Daw&HEWuzaz6sa&epHech_spAKucHaTH" }
      let(:ftp_host)     { "ftp.yundt.org" }
      let(:ftp_dir_raw)  { "/wordpress" }
      let(:ftp_dir)      { "/wordpress" }
      let(:host)         { "ftp.yundt.org" }
      let(:port)         { 21 }
      let(:has_port)     { false }
    end
  end

  context "blue" do
    it_should_behave_like "ftp named configuration" do
      let(:name)         { "blue" }
      let(:ftp_user)     { "harrison" }
      let(:ftp_password) { "w5@reba?9?pepuk7w9a#H86ustaGawE!" }
      let(:ftp_host)     { "ftp.torphagenes.com" }
      let(:ftp_dir_raw)  { "/wordpress" }
      let(:ftp_dir)      { "/wordpress" }
      let(:host)         { "ftp.torphagenes.com" }
      let(:port)         { 21 }
      let(:has_port)     { false }
    end
  end

  it "has methods that allow for interactive overwrite" do
    expect { subject.transmit }.to raise_error(NotImplementedError)
    expect { subject.receive }.to raise_error(NotImplementedError)
  end

  it { should respond_to :transmit! }
  it { should respond_to :receive! }

  context "FTP connection" do
    before(:each) do
      @ftp = double("ftp")
      @ftp.should_receive(:connect).with("localhost", 21)
      @ftp.should_receive(:login).with("root", "q9&hu6Re_*dReWr_GAba_2wr89#2Ra8$")
      @ftp.should_receive(:passive=).with(true)
      @ftp.stub(:pwd)
      @ftp.stub(:closed?).and_return(false)
      @ftp.stub(:close)
      @ftp.stub(:chdir)
      @ftp.stub(:putbinaryfile)
      Net::FTP.stub(:new).and_return(@ftp)
      WordpressDeploy::TransferProtocols::Ftp.any_instance.stub(:ftp).and_return(@ftp)
    end

    it "with valid credentials" do
      ftp = WordpressDeploy::TransferProtocols::Ftp.new("developer")
    end

    it "close an open connection" do
      ftp = WordpressDeploy::TransferProtocols::Ftp.new("developer")
      ftp.close.should be_true
      #ftp.close.should be_false
    end

    it "should send files" do
      files = Dir.glob(File.join(data_dir, "**/*"))

      Dir.should_receive(:glob).with("/Users/ryan/Source/wordpress-deploy/spec/data/**/*").and_return(files)

      ftp = WordpressDeploy::TransferProtocols::Ftp.new("developer")

      ftp.should_receive(:put_file).exactly(files.count).times

      ftp.transmit!
    end
  end

end
