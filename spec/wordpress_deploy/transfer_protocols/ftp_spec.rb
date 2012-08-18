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

  it_should_behave_like "Wordpress::ConfigurationFile mixin"

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

      Dir.should_receive(:glob).with("#{data_dir}/**/*").and_return(files)

      ftp = WordpressDeploy::TransferProtocols::Ftp.new("developer")

      ftp.should_receive(:put_file).exactly(files.count).times

      ftp.transmit!
    end
  end

end
