require 'spec_helper'

describe WordpressDeploy::Wordpress::Salts do

  it { should respond_to :auth_key }
  it { should respond_to :secure_auth_key }
  it { should respond_to :logged_in_key }
  it { should respond_to :nonce_key }
  it { should respond_to :auth_salt }
  it { should respond_to :secure_auth_salt }
  it { should respond_to :logged_in_salt }
  it { should respond_to :nonce_salt }

  it "should have a static method that generates psuedo random salts" do
    arr = 4.times.map { WordpressDeploy::Wordpress::Salts.salt }
    arr.should have(4).strings
    arr.each { |salt| salt.should be_salt}
  end

  context "should allow all the salts to be defined" do
    subject do
      WordpressDeploy::Wordpress::Salts.new do
        auth_key         '*oH{(q=`tIzdNJKUk$XfHNNjKd$W=f$S`CtD.,;x0R}$/A,}]!+q0>>QfB#.Bsw]'
        secure_auth_key  '{yg|7Q*j-?$%`b|Z!+5U,pvM,eA0+$/ruprp.mO[;|fExU:n0,-!at0+3UY@;h`X'
        logged_in_key    'k]N 9I<-rZq#k Xg)IPhv$E*ktbD7Z_AtI){U;(P;0r#LJlYncEr%8v9tG`>BHU+'
        nonce_key        ' /w9->::-YB Xa#lf%TPH+cIf?]Ru4OfKGF2h8PHsa)2,n-~kRJ<[slUg<GZ Asx'
        auth_salt        'VYwGGP,#|9P[5RCUTdv2c8)`^{dotU0fWrU`JE9qq^n=F4//e)fCs<HF6sd>~yjW'
        secure_auth_salt 'ok}@vSs=n6%_%UCO|&[?Jc;,-,.#Q3}zR4ej%IoAL7RavTN/Xe,UrQ4)p}onRie0'
        logged_in_salt   'Z!,C*:Q_I9A`[pJm-b0Z/(Gm2qvK8>0~| T&)lM+sxG.OdEmgHbAGF&(^>2.rDGW'
        nonce_salt       'ay)${bFV=F1KH[`NZ+W+Zk?Hc:@}jN}Ec)+Zn[F1fyP,mwi|@tk/(1hdp[G2F%os'
      end
    end
    its(:auth_key)         { should be_salt }
    its(:auth_key)         { should eq '*oH{(q=`tIzdNJKUk$XfHNNjKd$W=f$S`CtD.,;x0R}$/A,}]!+q0>>QfB#.Bsw]' }

    its(:secure_auth_key)  { should be_salt }
    its(:secure_auth_key)  { should eq '{yg|7Q*j-?$%`b|Z!+5U,pvM,eA0+$/ruprp.mO[;|fExU:n0,-!at0+3UY@;h`X' }

    its(:logged_in_key)    { should be_salt }
    its(:logged_in_key)    { should eq 'k]N 9I<-rZq#k Xg)IPhv$E*ktbD7Z_AtI){U;(P;0r#LJlYncEr%8v9tG`>BHU+' }

    its(:nonce_key)        { should be_salt }
    its(:nonce_key)        { should eq ' /w9->::-YB Xa#lf%TPH+cIf?]Ru4OfKGF2h8PHsa)2,n-~kRJ<[slUg<GZ Asx' }

    its(:auth_salt)        { should be_salt }
    its(:auth_salt)        { should eq 'VYwGGP,#|9P[5RCUTdv2c8)`^{dotU0fWrU`JE9qq^n=F4//e)fCs<HF6sd>~yjW' }

    its(:secure_auth_salt) { should be_salt }
    its(:secure_auth_salt) { should eq 'ok}@vSs=n6%_%UCO|&[?Jc;,-,.#Q3}zR4ej%IoAL7RavTN/Xe,UrQ4)p}onRie0' }

    its(:logged_in_salt)   { should be_salt }
    its(:logged_in_salt)   { should eq 'Z!,C*:Q_I9A`[pJm-b0Z/(Gm2qvK8>0~| T&)lM+sxG.OdEmgHbAGF&(^>2.rDGW' }

    its(:nonce_salt)       { should be_salt }
    its(:nonce_salt)       { should eq 'ay)${bFV=F1KH[`NZ+W+Zk?Hc:@}jN}Ec)+Zn[F1fyP,mwi|@tk/(1hdp[G2F%os' }
  end

  context "should define salts even if none are defined" do
    subject { WordpressDeploy::Wordpress::Salts.new }
    its(:auth_key)         { should be_salt }
    its(:secure_auth_key)  { should be_salt }
    its(:logged_in_key)    { should be_salt }
    its(:nonce_key)        { should be_salt }
    its(:auth_salt)        { should be_salt }
    its(:secure_auth_salt) { should be_salt }
    its(:logged_in_salt)   { should be_salt }
    its(:nonce_salt)       { should be_salt }
  end

end
