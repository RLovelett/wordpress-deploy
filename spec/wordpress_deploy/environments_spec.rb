require 'spec_helper'

describe WordpressDeploy::Environments do
  it { should respond_to :load }
  it { should respond_to :<< }
  it { should respond_to :available_names }
  it { should respond_to :names }
  it { should respond_to :name? }
  it { should respond_to :find }

  context "loading and accessing configuration files" do
    its(:names) { should have(5).symbols }
    its(:names) { should include :development }
    its(:names) { should include :production }
    its(:names) { should include :red }
    its(:names) { should include :green }
    its(:names) { should include :blue }
    its(:available_names) { should have(5).symbols }
    its(:available_names) { should include :development }
    its(:available_names) { should include :production }
    its(:available_names) { should include :red }
    its(:available_names) { should include :green }
    its(:available_names) { should include :blue }

    it { should respond_to :development }
    it { should respond_to :production }
    it { should respond_to :red }
    it { should respond_to :green }
    it { should respond_to :blue }

    its(:development) { should be_instance_of WordpressDeploy::Environment }
    its(:production)  { should be_instance_of WordpressDeploy::Environment }
    its(:red)         { should be_instance_of WordpressDeploy::Environment }
    its(:green)       { should be_instance_of WordpressDeploy::Environment }
    its(:blue)        { should be_instance_of WordpressDeploy::Environment }
  end

  context "check for valid names" do
    it "should validate :development" do
      subject.name?(:development).should be_true
    end
    it "should validate :production" do
      subject.name?(:production).should be_true
    end
    it "should validate :red" do
      subject.name?(:red).should be_true
    end
    it "should validate :green" do
      subject.name?(:green).should be_true
    end
    it "should validate :blue" do
      subject.name?(:blue).should be_true
    end
    it "should not validate :cool" do
      subject.name?(:cool).should be_false
    end
  end

  context "allow method to find a name" do
    it "should not validate :cool" do
      expect { subject.find(:cool) }.to raise_error(Exception)
    end
  end

end
