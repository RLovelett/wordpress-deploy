require 'spec_helper'
require 'tempfile'

describe WordpressDeploy::Environment do
  let(:tmp_file) do
    tmp = Tempfile.new ["wp-config", ".php"]
    path = tmp.path
    tmp.unlink
    path
  end

  let(:wp_config_out) { File.read(File.join(data_dir, "wp-config.php")) }

  let(:sample_configuration) do
    WordpressDeploy::Environment.new(:sample, false) do

      wplang "de_DE"
      wpdebug true

      database do
        name "production_database_name"
        user "some_user"
        password "trecuwawraJaZe6P@kucraDrachustUq"
        host "abbott.biz:6654"
        charset "utf8"
        collate "ryan-collate"
        table_prefix "ryan_";
      end

      salts do
        auth_key         '<r-*;SgTbz7&}VlyE.[H,F~4GB+s>)MRm9Y8KuUw{c15!Q3i/vIqtA^|jOPa6feW'
        secure_auth_key  'a%*bxGH)us+mQOPh7[I2$U{;Eijk.r#w!T>NZz&S?<V:AWY~vyC]3odLe}q9D56t'
        logged_in_key    'k#>.*)5W,V|OJSHRF?;dvmb/{LGg8hNB2ZQK]s$0+-1Itw7ux^YElr@9fn6i<P4j'
        nonce_key        'hCOW{xmyPG*z;oYJtgRvMFrnI.k0%&1KL,ewUT^2!>up=E:QD/)+d[|6$#?qSs]<'
        auth_salt        '~qC3]YB&ou/ry6<z{-WhPNR|I.mL2)XdHS+1p}?Ql^MKEiGA(>:f=#tc%;84Tkx7'
        secure_auth_salt 'RF,ZU<H^$Cgq}8S&[Y4zE65OBW(+.:0LDMGlr/ujk#JT{-?;29iyP*d~)nVp1cbe'
        logged_in_salt   'aT6q#EXyj3s*=Qf%0doLFc$?@O4i:S)I[GZRH/PWJw{^mY8(N,.xpMVD91etnv}&'
        nonce_salt       'FSOjHgapy-3b>&B^c@Pzw49ALqZ!<M7uvGJUnV;t#.C/kxoX:5*}{21=hsRT?l8,'
      end

    end
  end

  context "sample working configuration" do
    subject { sample_configuration }

    it { should respond_to :name }
    it { should respond_to :database }
    it { should respond_to :transfer }

    its(:name)    { should eq :sample }
    its(:wplang)  { should eq "de_DE" }
    its(:wpdebug) { should eq "true" }

    context "database configuration" do
      # TODO this probably should not be tested here It is extremely well
      # tested in spec/wordpress_deploy/database/environment_spec.rb
      subject { sample_configuration.database.env }
      its(:name)         { should eq "production_database_name" }
      its(:user)         { should eq "some_user" }
      its(:password)     { should eq "trecuwawraJaZe6P@kucraDrachustUq" }
      its(:host)         { should eq "abbott.biz" }
      its(:charset)      { should eq "utf8" }
      its(:collate)      { should eq "ryan-collate" }
      its(:table_prefix) { should eq "ryan_" }
    end

    context "save wp-config.php" do
      before(:each) do
        WordpressDeploy::Environment.stub(:output_file).and_return(tmp_file)
      end
      it "should save the wp-config.php file" do
        # Remove the file from the filesystem (if it exists)
        FileUtils.rm(tmp_file) if File.exists?(tmp_file)

        # Try saving it
        subject.save_wp_config

        # Check that it now exists
        File.exists?(tmp_file).should be_true

        # Remove the file from the filesystem (if it exists)
        FileUtils.rm(tmp_file) if File.exists?(tmp_file)
      end

      it "should have all of the correct values" do
        file = mock('file')
        file.should_receive(:write).with(wp_config_out)
        File.should_receive(:open).with(tmp_file, 'w').and_yield(file)

        # Try saving the file
        subject.save_wp_config
      end
    end

  end

end
