require 'spec_helper'

include WordpressDeploy::Database

describe WordpressDeploy::Database::OptionFile do
  let(:user) { 'ryan' }
  let(:password) { 'password with spaces' }
  let(:hostname) { 'localhost' }
  let(:port) { 3306 }
  let(:database) { 'db' }

  let(:mysql_option_file) do
    OptionFile.new(
        user,
        password,
        hostname,
        port,
        database,
        :mysql
    )
  end
  let(:mysqldump_option_file) do
    OptionFile.new(
        user,
        password,
        hostname,
        port,
        database,
        :mysqldump
    )
  end
  let(:mysql_contents) do
    f = File.open(mysql_option_file.path)
    f.read
  end
  let(:mysqldump_contents) do
    f = File.open(mysqldump_option_file.path)
    f.read
  end

  context 'mysql' do
    it { File.exists?(mysql_option_file.path).should be_true }
    it 'should have correct values' do
      mysql_contents.should eq <<-EOS
[client]
user=#{user}
password=#{password}
host=#{hostname}
port=#{port}
database=#{database}
EOS
    end
  end

  context 'mysqldump' do
    it { File.exists?(mysqldump_option_file.path).should be_true }
    it 'should have correct values' do
      mysqldump_contents.should eq <<-EOS
[client]
user=#{user}
password=#{password}
host=#{hostname}
port=#{port}
set-gtid-purged=off
      EOS
    end
  end
end