
module WordpressDeploy
  module ConfigurationFile

    def initialize(config_name=nil)
      self.name = config_name unless config_name.nil?
    end

    ##
    # Should always point to the raw yaml object that the current
    # Configs configuration directory contains.
    def yaml
      # Set the current configuration directory
      @config_dir ||= Config.config_dir

      # Force change of the configuration
      if @config_dir != Config.config_dir || @yaml.nil?
        @yaml = YAML.load_file(File.join(@config_dir, "wp-config.yml"))
      end

      # Return the loaded yaml
      @yaml
    end

    ##
    #
    def available_names
      yaml.map { |key, val| key }
    end
    alias :names :available_names

    ##
    # Return the configuration's name.
    #
    # Defaults to the first configuration name.
    def name
      @name ||= available_names.first
      @name
    end

    ##
    # Set the configuration's name.
    #
    # Only performs the assignment if the proposed name is
    # an available name.
    #
    # Returns the Configuration's name.
    def name=(new_name)
      @name = new_name if name? new_name
      @name
    end

    ##
    # Test if the name passed in is an available configuration
    # name.
    def name?(name_to_check)
      available_names.include? name_to_check
    end

    ##
    # Extract just the port number from the DB_HOST
    # configuration file. Or return the default port of 3306.
    def db_port
      port = 3306
      match = /:(?<port>\d+)$/.match(send(:DB_HOST))
      port = match[:port].to_i unless match.nil?
      port
    end

    ##
    # Does DB_HOST contain a port number?
    def db_port?
      !(send(:DB_HOST) =~ /:(?<port>\d+)$/).nil?
    end

    ##
    # Get just the hostname from DB_HOST. Only different from
    # DB_HOST if DB_HOST has a socket or a port number in it.
    def db_hostname
      host = "localhost"
      match = /(?<host>.*?)(?=:|$)/.match(send(:DB_HOST))
      host = match[:host].to_s unless match.nil?
      host
    end

    ##
    # Extract just the socket part from the DB_HOST
    # configuration file. Or return an empty string if none.
    def db_socket
      socket = ""
      match = /:(?<socket>\/.*)$/.match(send(:DB_HOST))
      socket = match[:socket].to_s unless match.nil?
      socket
    end

    ##
    # Does DB_HOST contain a socket path?
    def db_socket?
      !(send(:DB_HOST) =~ /:(?<socket>\/.*)$/).nil?
    end

    ##
    # Get just the hostname from DB_HOST. Only different from
    # FTP_HOST if FTP_HOST has a port number in it.
    def ftp_hostname
      host = "localhost"
      match = /(?<host>.*?)(?=:|$)/.match(send(:FTP_HOST))
      host = match[:host].to_s unless match.nil?
      host
    end

    ##
    #
    def ftp_username
      send(:FTP_USER) || ""
    end

    ##
    #
    def ftp_password
      send(:FTP_PASSWORD) || ""
    end

    ##
    #
    def ftp_port
      port = 21
      match = /:(?<port>\d+)$/.match(send(:FTP_HOST))
      port = match[:port].to_i unless match.nil?
      port
    end

    ##
    # Does FTP_HOST contain a port number?
    def ftp_port?
      !(send(:FTP_HOST) =~ /:(?<port>\d+)$/).nil?
    end

    def ftp_local_path
      Config.wp_dir
    end

    def ftp_remote_path
      ftp_dir = send(:FTP_DIR)
      return "/" if ftp_dir.nil?
      ftp_dir
    end


    WP_CONFIGURATION_ATTRIBUTES  = [:DB_NAME, :DB_USER, :DB_PASSWORD, :DB_HOST,
                                    :DB_CHARSET, :DB_COLLATE, :WPLANG,
                                    :WP_DEBUG]

    WP_CONFIGURATION_SALTS       = [:AUTH_KEY, :SECURE_AUTH_KEY,
                                    :LOGGED_IN_KEY, :NONCE_KEY, :AUTH_SALT,
                                    :SECURE_AUTH_SALT, :LOGGED_IN_SALT,
                                    :NONCE_SALT]

    WP_CONFIGURATION_ALL         = WP_CONFIGURATION_ATTRIBUTES +
                                   WP_CONFIGURATION_SALTS

    FTP_CONFIGURATION_ATTRIBUTES = [:FTP_DIR, :FTP_USER, :FTP_PASSWORD,
                                    :FTP_HOST]

    ALL_CONFIGURATION_OPTIONS    = WP_CONFIGURATION_ALL +
                                   FTP_CONFIGURATION_ATTRIBUTES

    # Define the behaviours of the default parameters quickly
    def method_missing(meth, *args, &block)
      # Convert the method to a symbol
      method_symbol = meth.to_sym

      if WP_CONFIGURATION_ATTRIBUTES.include? method_symbol
        config = yaml[name]
        return config[meth.to_s] if config.include? meth.to_s
        ""
      elsif WP_CONFIGURATION_SALTS.include? method_symbol
        config = yaml[name]
        if config.include? meth.to_s
          config[meth.to_s]
        else
          # Return salt if the method is a salting method
          Wordpress::Configuration.salt
        end
      elsif  FTP_CONFIGURATION_ATTRIBUTES.include? method_symbol
        config = yaml[name]
        return config[meth.to_s] if config.include? meth.to_s
      else
        # You *must* call super if you don't handle the method, otherwise
        # you will mess up Ruby's method lookup.
        super
      end
    end

    ##
    # Define respond_to?
    def respond_to?(method)
      return true if ALL_CONFIGURATION_OPTIONS.include? method.to_sym
      super
    end

  end
end

