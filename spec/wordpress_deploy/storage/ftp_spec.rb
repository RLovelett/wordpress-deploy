require 'spec_helper'

include WordpressDeploy

describe WordpressDeploy::Storage::Ftp do
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

  it "has methods that allow for interactive overwrite" do
    expect { subject.transmit }.to raise_error(NotImplementedError)
    expect { subject.receive }.to raise_error(NotImplementedError)
  end

  it { should respond_to :transmit! }
  it { should respond_to :receive! }

  context "FTP connection" do
    before(:each) do
      @ftp = double("ftp")
      @ftp.should_receive(:connect).with("ftp.hanerutherford.biz", 77)
      @ftp.should_receive(:login).with("red_user", "Bun__huPEMeBreM6tebRAp@eguzuQExe")
      @ftp.should_receive(:passive=).with(true)
      @ftp.stub(:pwd)
      @ftp.stub(:closed?).and_return(false)
      @ftp.stub(:close)
      @ftp.stub(:chdir)
      @ftp.stub(:putbinaryfile)
      Net::FTP.stub(:new).and_return(@ftp)
      WordpressDeploy::Storage::Ftp.any_instance.stub(:ftp).and_return(@ftp)
    end

    it "should send files" do
      files = Dir.glob(File.join(data_dir, "**/*"))

      Dir.should_receive(:glob).with("#{data_dir}/**/*").and_return(files)

      ftp = WordpressDeploy::Storage::Ftp.new do
        host "ftp.hanerutherford.biz:77"
        user "red_user"
        password "Bun__huPEMeBreM6tebRAp@eguzuQExe"
        destination "/html"
      end

      ftp.should_receive(:put_file).exactly(files.count).times

      ftp.transmit!
    end
  end

end
