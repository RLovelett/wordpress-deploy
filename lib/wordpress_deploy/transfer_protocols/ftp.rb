##
# Only load the Net::FTP library/gem when the
# WordpressDeploy::TransferProtocols::Ftp class is loaded
require "net/ftp"
require "pathname"
require "action_view"

module WordpressDeploy
  module TransferProtocols
    class Ftp
      include ActionView::Helpers::NumberHelper

      attr_reader :configuration
      attr_accessor :available_names
      alias :names :available_names

      ##
      # Create a new instance of the Ftp object
      def initialize(config_name = nil)
        # Set the configuration
        @yaml             = YAML.load_file(File.join(Environment.config_dir, "wp-config.yml"))
        @available_names  = @yaml.map { |key, val| key }

        self.name = config_name unless config_name.nil?

        # Actually open the connection
        connect
      end

      def configuration=(new_config)
        @configuration = new_config if new_config.instance_of? WordpressDeploy::Wordpress::Configuration
      end

      def transmit
        raise NotImplementedError
      end

      def transmit!

      end

      def receive
        raise NotImplementedError
      end

      def receive!

      end

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

      def local_path
        Environment.wp_dir
      end

      def remote_path
        ftp_dir = send(:FTP_DIR)
        return "/" if ftp_dir.nil?
        ftp_dir
      end

      def username
        send(:FTP_USER) || ""
      end

      def password
        send(:FTP_PASSWORD) || ""
      end

      def port
        port = 21
        match = /:(?<port>\d+)$/.match(send(:FTP_HOST))
        port = match[:port].to_i unless match.nil?
        port
      end

      ##
      # Does FTP_HOST contain a port number?
      def port?
        !(send(:FTP_HOST) =~ /:(?<port>\d+)$/).nil?
      end

      ##
      # Get just the hostname from DB_HOST. Only different from
      # FTP_HOST if FTP_HOST has a port number in it.
      def host
        host = "localhost"
        match = /(?<host>.*?)(?=:|$)/.match(send(:FTP_HOST))
        host = match[:host].to_s unless match.nil?
        host
      end

      FTP_CONFIGURATION_ATTRIBUTES = [:FTP_DIR, :FTP_USER, :FTP_PASSWORD,
                                      :FTP_HOST]

      ##
      # Define the behaviours of the default parameters quickly
      def method_missing(meth, *args, &block)
        # Convert the method to a symbol
        method_symbol = meth.to_sym

        if FTP_CONFIGURATION_ATTRIBUTES.include? method_symbol
          config = @yaml[name]
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
        return true if FTP_CONFIGURATION_ATTRIBUTES.include? method.to_sym
        super
      end

      private

      def local_path
        Environment.wp_dir
      end

      ##
      # Establish a connection to the remote server
      def connect

        # If the user defined a port
        if port?
          # Unset the FTP port number if it is defined
          if Net::FTP.const_defined?(:FTP_PORT)
            Net::FTP.send(:remove_const, :FTP_PORT)
          end

          # Set it to the user defined or default value
          Net::FTP.send(:const_set, :FTP_PORT, port)
        end

        # Now open the connection to the remote machine
        @ftp = Net::FTP.new(host, username, password)

      end

    end
  end
end

