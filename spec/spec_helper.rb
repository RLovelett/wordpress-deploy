require 'rubygems'
require 'bundler/setup'

require 'wordpress_deploy'

def data_dir
  File.join(File.dirname(__FILE__), "data")
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Reset the environment for each spec that is run
  config.before(:each) do
    WordpressDeploy::Config.root_dir    = data_dir
    WordpressDeploy::Config.wp_dir      = "."
    WordpressDeploy::Config.config_dir  = "."
    WordpressDeploy::Config.logging     = false
  end

  # Clean-up log files after each spec
  config.after(:all) do
    WordpressDeploy::Config.clean!
  end

  shared_examples "Wordpress::ConfigurationFile mixin" do
    it { should respond_to :name }
    it { should respond_to :name= }
    it { should respond_to :available_names }
    it { should respond_to :names }

    it { should respond_to :ftp_port }
    it { should respond_to :ftp_port? }
    it { should respond_to :ftp_hostname }

    it { should respond_to :FTP_USER }
    it { should respond_to :FTP_PASSWORD }
    it { should respond_to :FTP_HOST }
    it { should respond_to :FTP_DIR }

    it { should respond_to :db_port }
    it { should respond_to :db_port? }
    it { should respond_to :db_hostname }
    it { should respond_to :db_socket }
    it { should respond_to :db_socket? }

    it { should respond_to :DB_NAME }
    it { should respond_to :DB_USER }
    it { should respond_to :DB_PASSWORD }
    it { should respond_to :DB_HOST }
    it { should respond_to :DB_CHARSET }
    it { should respond_to :DB_COLLATE }
    it { should respond_to :WPLANG }
    it { should respond_to :WP_DEBUG }
    it { should respond_to :AUTH_KEY }
    it { should respond_to :SECURE_AUTH_KEY }
    it { should respond_to :LOGGED_IN_KEY }
    it { should respond_to :NONCE_KEY }
    it { should respond_to :AUTH_SALT }
    it { should respond_to :SECURE_AUTH_SALT }
    it { should respond_to :LOGGED_IN_SALT }
    it { should respond_to :NONCE_SALT }

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
      # Create a new instance of whatever class is the subject
      # of this spec. Pass this new intance the configuration
      # name of 'red'
      instance = subject.class.new "red"

      # Make sure it's name is 'red'
      instance.name.should eq "red"
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

    context "for each available named configuration" do
      context "\"development\"" do
        before (:each) { subject.name = "development" }
        its(:name)             { should eq "development" }
        its(:FTP_USER)         { should eq "root" }
        its(:FTP_PASSWORD)     { should eq "q9&hu6Re_*dReWr_GAba_2wr89#2Ra8$" }
        its(:FTP_HOST)         { should eq "localhost" }
        its(:FTP_DIR)          { should eq "/wordpress" }
        its(:ftp_local_path)   { should eq WordpressDeploy::Config.wp_dir }
        its(:ftp_remote_path)  { should eq "/wordpress" }
        its(:ftp_username)     { should eq "root" }
        its(:ftp_password)     { should eq "q9&hu6Re_*dReWr_GAba_2wr89#2Ra8$" }
        its(:ftp_hostname)     { should eq "localhost" }
        its(:ftp_port)         { should eq 21 }
        its(:ftp_port?)        { should eq false }

        its(:DB_NAME)          { should eq "developer_database_name" }
        its(:DB_USER)          { should eq "root" }
        its(:DB_PASSWORD)      { should eq "q9&hu6Re_*dReWr_GAba_2wr89#2Ra8$" }
        its(:DB_HOST)          { should eq "localhost" }
        its(:DB_CHARSET)       { should eq "utf8" }
        its(:DB_COLLATE)       { should eq "" }
        its(:WPLANG)           { should eq "" }
        its(:WP_DEBUG)         { should be_true }
        its(:AUTH_KEY)         { should be_salt }
        its(:SECURE_AUTH_KEY)  { should be_salt }
        its(:LOGGED_IN_KEY)    { should be_salt }
        its(:NONCE_KEY)        { should be_salt }
        its(:AUTH_SALT)        { should be_salt }
        its(:SECURE_AUTH_SALT) { should be_salt }
        its(:LOGGED_IN_SALT)   { should be_salt }
        its(:NONCE_SALT)       { should be_salt }
        its(:db_port)          { should eq 3306 }
        its(:db_port?)         { should eq false }
        its(:db_hostname)      { should eq "localhost" }
        its(:db_socket)        { should eq "" }
        its(:db_socket?)       { should eq false }
      end
      context "\"production\"" do
        before (:each) { subject.name = "production" }
        its(:name)             { should eq "production" }
        its(:FTP_USER)         { should eq "some_user" }
        its(:FTP_PASSWORD)     { should eq "trecuwawraJaZe6P@kucraDrachustUq" }
        its(:FTP_HOST)         { should eq "ftp.abbott.biz:6655" }
        its(:FTP_DIR)          { should eq nil }
        its(:ftp_local_path)   { should eq WordpressDeploy::Config.wp_dir }
        its(:ftp_remote_path)  { should eq "/" }
        its(:ftp_username)     { should eq "some_user" }
        its(:ftp_password)     { should eq "trecuwawraJaZe6P@kucraDrachustUq" }
        its(:ftp_hostname)     { should eq "ftp.abbott.biz" }
        its(:ftp_port)         { should eq 6655 }
        its(:ftp_port?)        { should eq true }

        its(:DB_NAME)          { should eq "production_database_name" }
        its(:DB_USER)          { should eq "some_user" }
        its(:DB_PASSWORD)      { should eq "trecuwawraJaZe6P@kucraDrachustUq" }
        its(:DB_HOST)          { should eq "abbott.biz:6654" }
        its(:DB_CHARSET)       { should eq "utf8" }
        its(:DB_COLLATE)       { should eq "" }
        its(:WPLANG)           { should eq "" }
        its(:WP_DEBUG)         { should be_true }
        its(:AUTH_KEY)         { should be_salt }
        its(:SECURE_AUTH_KEY)  { should be_salt }
        its(:LOGGED_IN_KEY)    { should be_salt }
        its(:NONCE_KEY)        { should be_salt }
        its(:AUTH_SALT)        { should be_salt }
        its(:SECURE_AUTH_SALT) { should be_salt }
        its(:LOGGED_IN_SALT)   { should be_salt }
        its(:NONCE_SALT)       { should be_salt }
        its(:db_port)          { should eq 6654 }
        its(:db_port?)         { should eq true }
        its(:db_hostname)      { should eq "abbott.biz" }
        its(:db_socket)        { should eq "" }
        its(:db_socket?)       { should eq false }
      end
      context "\"red\"" do
        before (:each) { subject.name = "red" }
        its(:name)             { should eq "red" }
        its(:FTP_USER)         { should eq "red_user" }
        its(:FTP_PASSWORD)     { should eq "Bun__huPEMeBreM6tebRAp@eguzuQExe" }
        its(:FTP_HOST)         { should eq "ftp.hanerutherford.biz" }
        its(:FTP_DIR)          { should eq "/html" }
        its(:ftp_local_path)   { should eq WordpressDeploy::Config.wp_dir }
        its(:ftp_remote_path)  { should eq "/html" }
        its(:ftp_username)     { should eq "red_user" }
        its(:ftp_password)     { should eq "Bun__huPEMeBreM6tebRAp@eguzuQExe" }
        its(:ftp_hostname)     { should eq "ftp.hanerutherford.biz" }
        its(:ftp_port)         { should eq 21 }
        its(:ftp_port?)        { should eq false }

        its(:DB_NAME)          { should eq "red" }
        its(:DB_USER)          { should eq "red_user" }
        its(:DB_PASSWORD)      { should eq "Bun__huPEMeBreM6tebRAp@eguzuQExe" }
        its(:DB_HOST)          { should eq "hanerutherford.biz" }
        its(:DB_CHARSET)       { should eq "utf8" }
        its(:DB_COLLATE)       { should eq "" }
        its(:WPLANG)           { should eq "" }
        its(:WP_DEBUG)         { should be_true }
        its(:AUTH_KEY)         { should be_salt }
        its(:SECURE_AUTH_KEY)  { should be_salt }
        its(:LOGGED_IN_KEY)    { should be_salt }
        its(:NONCE_KEY)        { should be_salt }
        its(:AUTH_SALT)        { should be_salt }
        its(:SECURE_AUTH_SALT) { should be_salt }
        its(:LOGGED_IN_SALT)   { should be_salt }
        its(:NONCE_SALT)       { should be_salt }

        its(:AUTH_KEY)         { should eq "*oH{(q=`tIzdNJKUk$XfHNNjKd$W=f$S`CtD.,;x0R}$/A,}]!+q0>>QfB#.Bsw]" }
        its(:SECURE_AUTH_KEY)  { should eq "{yg|7Q*j-?$%`b|Z!+5U,pvM,eA0+$/ruprp.mO[;|fExU:n0,-!at0+3UY@;h`X" }
        its(:LOGGED_IN_KEY)    { should eq "k]N 9I<-rZq#k Xg)IPhv$E*ktbD7Z_AtI){U;(P;0r#LJlYncEr%8v9tG`>BHU+" }
        its(:NONCE_KEY)        { should eq " /w9->::-YB Xa#lf%TPH+cIf?]Ru4OfKGF2h8PHsa)2,n-~kRJ<[slUg<GZ Asx" }
        its(:AUTH_SALT)        { should eq "VYwGGP,#|9P[5RCUTdv2c8)`^{dotU0fWrU`JE9qq^n=F4//e)fCs<HF6sd>~yjW" }
        its(:SECURE_AUTH_SALT) { should eq "ok}@vSs=n6%_%UCO|&[?Jc;,-,.#Q3}zR4ej%IoAL7RavTN/Xe,UrQ4)p}onRie0" }
        its(:LOGGED_IN_SALT)   { should eq "Z!,C*:Q_I9A`[pJm-b0Z/(Gm2qvK8>0~| T&)lM+sxG.OdEmgHbAGF&(^>2.rDGW" }
        its(:NONCE_SALT)       { should eq "ay)${bFV=F1KH[`NZ+W+Zk?Hc:@}jN}Ec)+Zn[F1fyP,mwi|@tk/(1hdp[G2F%os" }

        its(:db_port)          { should eq 3306 }
        its(:db_port?)         { should eq false }
        its(:db_hostname)      { should eq "hanerutherford.biz" }
        its(:db_socket)        { should eq "" }
        its(:db_socket?)       { should eq false }
      end
      context "\"green\"" do
        before (:each) { subject.name = "green" }
        its(:name)             { should eq "green" }
        its(:FTP_USER)         { should eq "domenick.dare" }
        its(:FTP_PASSWORD)     { should eq "Daw&HEWuzaz6sa&epHech_spAKucHaTH" }
        its(:FTP_HOST)         { should eq "ftp.yundt.org" }
        its(:FTP_DIR)          { should eq "/wordpress" }
        its(:ftp_local_path)   { should eq WordpressDeploy::Config.wp_dir }
        its(:ftp_remote_path)  { should eq "/wordpress" }
        its(:ftp_username)     { should eq "domenick.dare" }
        its(:ftp_password)     { should eq "Daw&HEWuzaz6sa&epHech_spAKucHaTH" }
        its(:ftp_hostname)     { should eq "ftp.yundt.org" }
        its(:ftp_port)         { should eq 21 }
        its(:ftp_port?)        { should eq false }

        its(:DB_NAME)          { should eq "green" }
        its(:DB_USER)          { should eq "domenick.dare" }
        its(:DB_PASSWORD)      { should eq "Daw&HEWuzaz6sa&epHech_spAKucHaTH" }
        its(:DB_HOST)          { should eq "yundt.org" }
        its(:DB_CHARSET)       { should eq "utf8" }
        its(:DB_COLLATE)       { should eq "" }
        its(:WPLANG)           { should eq "" }
        its(:WP_DEBUG)         { should be_true }
        its(:AUTH_KEY)         { should be_salt }
        its(:SECURE_AUTH_KEY)  { should be_salt }
        its(:LOGGED_IN_KEY)    { should be_salt }
        its(:NONCE_KEY)        { should be_salt }
        its(:AUTH_SALT)        { should be_salt }
        its(:SECURE_AUTH_SALT) { should be_salt }
        its(:LOGGED_IN_SALT)   { should be_salt }
        its(:NONCE_SALT)       { should be_salt }
        its(:db_port)          { should eq 3306 }
        its(:db_port?)         { should eq false }
        its(:db_hostname)      { should eq "yundt.org" }
        its(:db_socket)        { should eq "" }
        its(:db_socket?)       { should eq false }
      end
      context "\"blue\"" do
        before (:each) { subject.name = "blue" }
        its(:name)             { should eq "blue" }
        its(:FTP_USER)         { should eq "harrison" }
        its(:FTP_PASSWORD)     { should eq "w5@reba?9?pepuk7w9a#H86ustaGawE!" }
        its(:FTP_HOST)         { should eq "ftp.torphagenes.com" }
        its(:FTP_DIR)          { should eq "/wordpress" }
        its(:ftp_local_path)   { should eq WordpressDeploy::Config.wp_dir }
        its(:ftp_remote_path)  { should eq "/wordpress" }
        its(:ftp_username)     { should eq "harrison" }
        its(:ftp_password)     { should eq "w5@reba?9?pepuk7w9a#H86ustaGawE!" }
        its(:ftp_hostname)     { should eq "ftp.torphagenes.com" }
        its(:ftp_port)         { should eq 21 }
        its(:ftp_port?)        { should eq false }

        its(:DB_NAME)          { should eq "blue" }
        its(:DB_USER)          { should eq "harrison" }
        its(:DB_PASSWORD)      { should eq "w5@reba?9?pepuk7w9a#H86ustaGawE!" }
        its(:DB_HOST)          { should eq "torphagenes.com:/tmp/mysql5.sock" }
        its(:DB_CHARSET)       { should eq "utf8" }
        its(:DB_COLLATE)       { should eq "" }
        its(:WPLANG)           { should eq "" }
        its(:WP_DEBUG)         { should be_true }
        its(:AUTH_KEY)         { should be_salt }
        its(:SECURE_AUTH_KEY)  { should be_salt }
        its(:LOGGED_IN_KEY)    { should be_salt }
        its(:NONCE_KEY)        { should be_salt }
        its(:AUTH_SALT)        { should be_salt }
        its(:SECURE_AUTH_SALT) { should be_salt }
        its(:LOGGED_IN_SALT)   { should be_salt }
        its(:NONCE_SALT)       { should be_salt }
        its(:db_port)          { should eq 3306 }
        its(:db_port?)         { should eq false }
        its(:db_hostname)      { should eq "torphagenes.com" }
        its(:db_socket)        { should eq "/tmp/mysql5.sock" }
        its(:db_socket?)       { should eq true }
      end
    end
  end

end

RSpec::Matchers.define :be_salt do |expected|
  match do |actual|
    actual.instance_of? String
    actual.to_s.size === 64
  end
end
