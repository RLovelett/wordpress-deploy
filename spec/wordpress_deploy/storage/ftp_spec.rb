require 'spec_helper'

include WordpressDeploy
include WordpressDeploy::Storage

# TODO
# * Test for Errno::ECONNREFUSED
# * Test for Errno::ECONNRESET
# * Test for Net::FTPPermError
# * Test for Net::FTPConnectionError

describe WordpressDeploy::Storage::Ftp.new do
  let(:control_port) { 21212 }
  let(:data_port)    { 21213 }
  let(:ftp_server)   { FakeFtp::Server.new(control_port, data_port) }
  let(:ftp_directory) { WordpressDeploy::Config.wp_dir }

  before(:each) do
    # Start and stop the fake FTP server between each test
    ftp_server.start
  end

  after(:each) do
    # Start and stop the fake FTP server between each test
    ftp_server.stop
  end


  context "default parameters" do
    its(:host) { should eq "localhost" }
    its(:port) { should eq 21 }
    its(:open?) { should be_false }
    its(:user) { should eq "root" }
    its(:password) { should eq "" }
  end

  describe WordpressDeploy::Storage::Ftp.new do
    before(:each) do
      subject.host "localhost:#{control_port}"
      subject.user "red_user"
      subject.password "Bun__huPEMeBreM6tebRAp@eguzuQExe"
      subject.destination "/html"
    end
    its(:port)  { should eq control_port }
    its(:host)  { should eq "localhost" }
    its(:open?) { should be_false }
    context "files" do
      before(:all) do
        # Start FakeFS
        FakeFS.activate!

        FileUtils.mkdir_p(ftp_directory)
        File.open(File.join(ftp_directory, "file1.txt"), "w") do |file|
          file.puts("ryan")
        end
      end

      after(:all) do
        # Stop the FakeFS
        FakeFS.deactivate!
      end
      its(:files) { should eq [File.join(ftp_directory, "file1.txt")] }
    end

    context "#transmit!" do
      let(:file_count) { subject.files.size }
      before(:each) { subject.transmit! }
      it { ftp_server.files.should have(file_count).file }
      it { ftp_server.files.should include("file1.txt") }
    end

    context "receive files" do
      before(:each) { subject.receive! }
      it "should have all the same files as the server"
    end
  end
end
