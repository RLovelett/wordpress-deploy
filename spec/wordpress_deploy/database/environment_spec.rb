require 'spec_helper'

include WordpressDeploy::Database
include WordpressDeploy::Wordpress

describe WordpressDeploy::Database::Environment do

  it { should respond_to :name }
  it { should respond_to :user }
  it { should respond_to :password }
  it { should respond_to :host }
  it { should respond_to :wp_host }
  it { should respond_to :port }
  it { should respond_to :port? }
  it { should respond_to :socket }
  it { should respond_to :socket? }
  it { should respond_to :charset }
  it { should respond_to :collate }
  it { should respond_to :table_prefix }
  it { should respond_to :base_url }
  it { should respond_to :file }

  context "with no user defined parameters" do
    its(:name)     { should eq "wordpress" }
    its(:user)     { should eq "root" }
    its(:password) { should eq "" }
    its(:host)     { should eq "localhost" }
    its(:wp_host)  { should eq "localhost" }
    its(:port)     { should eq 3306 }
    its(:port?)    { should be_false }
    its(:socket)   { should eq "" }
    its(:socket?)  { should be_false }
  end

  context "user defined paramaters" do
    let(:sample) { WordpressDeploy::Database::Environment.new }
    subject { sample }

    context "#name" do
      let(:name) { Faker::Company.name }
      context "assignment" do
        it { subject.name(name).should eq name }
      end
      context "reader" do
        before(:each) { subject.name(name) }
        its(:name) { should eq name }
      end
    end

    context "#user" do
      let(:user) { Faker::Internet.user_name }
      context "assignment" do
        it { subject.user(user).should eq user }
      end
      context "reader" do
        before(:each) { subject.user(user) }
        its(:user) { should eq user }
      end
    end

    context "#password" do
      let(:password) { "w5@reba?9?pepuk7w9a#H86ustaGawE!" }
      context "assignment" do
        it { subject.password(password).should eq password }
      end
      context "reader" do
        before(:each) { subject.password(password) }
        its(:password) { should eq password }
      end
    end

    context "connection string parsing" do
      context "only host" do
        let(:host) { Faker::Internet.domain_name }
        before(:each) { subject.host(host) }

        describe "#host" do
          its(:host) { should eq host }
          context "assignment" do
            let(:host) { Faker::Internet.domain_name }
            it { subject.host(host).should eq host }
          end
        end

        describe "#port" do
          its(:port) { should eq 3306 }
        end

        describe "#port?" do
          its(:port?) { should be_false }
        end

        describe "#socket" do
          its(:socket) { should eq "" }
        end

        describe "#socket?" do
          its(:socket?) { should be_false }
        end

        describe "#wp_host" do
          its(:wp_host) { should eq host }
        end
      end

      context "with port" do
        let(:host)        { Faker::Internet.domain_name }
        let(:port)        { 6654 }
        let(:host_w_port) { "#{host}:#{port}" }
        before(:each) { subject.host(host_w_port) }

        describe "#host" do
          its(:host) { should eq host }
          context "assignment" do
            let(:host)        { Faker::Internet.domain_name }
            let(:host_w_port) { "#{host}:#{port}" }
            it { subject.host(host_w_port).should eq host }
          end
        end

        describe "#port" do
          its(:port) { should eq port }
        end

        describe "#port?" do
          its(:port?) { should be_true }
        end

        describe "#socket" do
          its(:socket) { should eq "" }
        end

        describe "#socket?" do
          its(:socket?) { should be_false }
        end

        describe "#wp_host" do
          its(:wp_host) { should eq host_w_port }
        end
      end

      context "with socket" do
        let(:host)          { Faker::Internet.domain_name }
        let(:socket)        { "/tmp/mysql5.sock" }
        let(:host_w_socket) { "#{host}:#{socket}" }
        before(:each) { subject.host(host_w_socket) }

        describe "#host" do
          its(:host) { should eq host }
          context "assignment" do
            let(:host)          { Faker::Internet.domain_name }
            let(:host_w_socket) { "#{host}:#{socket}" }
            it { subject.host(host_w_socket).should eq host }
          end
        end

        describe "#port" do
          its(:port) { should eq 3306 }
        end

        describe "#port?" do
          its(:port?) { should be_false }
        end

        describe "#socket" do
          its(:socket) { should eq socket }
        end

        describe "#socket?" do
          its(:socket?) { should be_true }
        end

        describe "#wp_host" do
          its(:wp_host) { should eq host_w_socket }
        end
      end
    end
    # end context connection string parsing

    context "#charset" do
      # http://dev.mysql.com/doc/refman/5.0/en/charset-mysql.html
      let(:charset) { "hebrew" }
      context "assignment" do
        it { subject.charset(charset).should eq charset }
      end
      context "reader" do
        before(:each) { subject.charset(charset) }
        its(:charset) { should eq charset }
      end
    end

    context "#collate" do
      # http://dev.mysql.com/doc/refman/5.0/en/charset-mysql.html
      let(:collate) { "hebrew_general_ci" }
      context "assignment" do
        it { subject.collate(collate).should eq collate }
      end
      context "reader" do
        before(:each) { subject.collate(collate) }
        its(:collate) { should eq collate }
      end
    end

    context "#table_prefix" do
      let(:table_prefix) { "ry_" }
      context "assignment" do
        it { subject.table_prefix(table_prefix).should eq table_prefix }
      end
      context "reader" do
        before(:each) { subject.table_prefix(table_prefix) }
        its(:table_prefix) { should eq table_prefix }
      end
    end

    context "#base_url" do
      let(:base_url) { "http://#{Faker::Internet.domain_name}/" }
      context "assignment" do
        it { subject.base_url(base_url).should eq base_url }
      end
      context "reader" do
        before(:each) { subject.base_url(base_url) }
        its(:base_url) { should eq base_url }
      end
    end

    context "#file" do
      let(:name) { Faker::Company.name }
      let(:name_normalized) { name.gsub(/\W+/, "_").downcase }
      before(:each) { subject.name(name) }
      its(:file) { should match(/#{name_normalized}.sql$/) }
    end
  end
end
