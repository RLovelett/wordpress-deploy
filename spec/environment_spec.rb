require 'spec_helper'

describe WordpressDeploy::Environment do

  it { should respond_to :set_options }

  let(:new_options) do
    Hash["root_dir", "/some/new/dir", "wp_dir", "./dir2"]
  end

  it "should allow mass assignment of options" do
    subject.set_options new_options
    subject.root_dir.should eq "/some/new/dir"
    subject.wp_dir.should eq "/some/new/dir/dir2"
    subject.log_file.should =~ /\/some\/new\/dir/
  end

  its(:root_dir)     { should eq data_dir }
  its(:wp_dir)       { should eq data_dir }
  its(:log_file)     { should =~ /#{data_dir}.*.log/ }

  context "logs" do
    before(:all) { @log_before = WordpressDeploy::Environment.logging? }
    it "should default to logging off unless explicitly set to true" do
      WordpressDeploy::Environment.logging = true
      [:true, "true", 1, 0, false, :false, "Cool"].each do |val|
        WordpressDeploy::Environment.logging = val
        WordpressDeploy::Environment.logging?.should be_false
      end
    end
    its(:logging?) { should be_false }
    after(:all) { WordpressDeploy::Environment.logging = @log_before }
  end
end

