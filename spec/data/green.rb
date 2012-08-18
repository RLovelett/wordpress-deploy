##
# This is an example of a default WordpressDeploy configuration file. The
# values here are examples to show you what to do.
WordpressDeploy::Environment.new(:green) do

  base_url "localhost"

  ##
  # Connection and settings for the MySQL database that wordpress
  # connects to
  database do
    name "green"
    user "domenick.dare"
    password "Daw&HEWuzaz6sa&epHech_spAKucHaTH"
    host "yundt.org"
    charset "utf8"
    collate ""

    ##
    # If this parameter is not defined wp_
    # is assumed.
    table_prefix "wp_";
  end

  ##
  # Authentication Unique Keys and Salts
  # https://api.wordpress.org/secret-key/1.1/salt/
  # If no salts are supplied they will be generated automatically
  #
  # NOTE This entire block is optional
  salts do
    #auth_key         '*oH{(q=`tIzdNJKUk$XfHNNjKd$W=f$S`CtD.,;x0R}$/A,}]!+q0>>QfB#.Bsw]'
    #secure_auth_key  '{yg|7Q*j-?$%`b|Z!+5U,pvM,eA0+$/ruprp.mO[;|fExU:n0,-!at0+3UY@;h`X'
    #logged_in_key    'k]N 9I<-rZq#k Xg)IPhv$E*ktbD7Z_AtI){U;(P;0r#LJlYncEr%8v9tG`>BHU+'
    #nonce_key        ' /w9->::-YB Xa#lf%TPH+cIf?]Ru4OfKGF2h8PHsa)2,n-~kRJ<[slUg<GZ Asx'
    #auth_salt        'VYwGGP,#|9P[5RCUTdv2c8)`^{dotU0fWrU`JE9qq^n=F4//e)fCs<HF6sd>~yjW'
    #secure_auth_salt 'ok}@vSs=n6%_%UCO|&[?Jc;,-,.#Q3}zR4ej%IoAL7RavTN/Xe,UrQ4)p}onRie0'
    #logged_in_salt   'Z!,C*:Q_I9A`[pJm-b0Z/(Gm2qvK8>0~| T&)lM+sxG.OdEmgHbAGF&(^>2.rDGW'
    #nonce_salt       'ay)${bFV=F1KH[`NZ+W+Zk?Hc:@}jN}Ec)+Zn[F1fyP,mwi|@tk/(1hdp[G2F%os'
  end

  ##
  # Block defines the settings for the transfer of files
  # to this configuration.
  transfer :Ftp do
    host "ftp.yundt.org"
    user "domenick.dare"
    password "Daw&HEWuzaz6sa&epHech_spAKucHaTH"
    destination "/wordpress"
  end

end
