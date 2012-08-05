module WordpressDeploy
  module Wordpress

    class Configuration

      def initialize
        @template = File.join(Environment.wp_dir, "wp-config-sample.php")
        @output   = File.join(Environment.wp_dir, "wp-config.php")

        @yaml     = YAML.load_file(File.join(Environment.config_dir, "wp-config.yml"))
        @environment = @yaml[Environment.environment]
      end

      ##
      # Returns 64 psuedo-random characters as a string
      # Characters can be a-zA-z or !@#$%^&*()-~+=|/{}:;,.?<>[]
      def self.salt
        salt_array.sample(64).join("")
      end

      ##
      # The file that contains the template for the output file
      def template
        @template
      end

      ##
      # The file that will be output
      def output
        @output
      end

      ##
      # Write the file the filesystem
      def save!
        # Remove the output file if is already there
        FileUtils.rm @output if File.exists? @output

        # Open the output file
        output = File.open(@output, 'w')

        # Start parsing the template file
        File.open(@template, 'r') do |template|
          template.each_line do |line|
            match = /^define\(['"](?<parameter>\w*)['"]/.match(line)
            unless match.nil?
              # Get named capture group from Regular Expression
              param = match[:parameter]

              # Get the value for the specified parameter
              value = send(param)

              # Set the definition of the line
              line = define(param, value)
            end
            output.puts(line)
          end
        end

      ensure
        # Close the output file if it is open
        # even if an exception occurs
        output.close if output
      end

      WP_CONFIGURATION_ATTRIBUTES = [:DB_NAME, :DB_USER, :DB_PASSWORD, :DB_HOST,
                                     :DB_CHARSET, :DB_COLLATE, :WPLANG,
                                     :WP_DEBUG]

      WP_CONFIGURATION_SALTS      = [:AUTH_KEY, :SECURE_AUTH_KEY,
                                     :LOGGED_IN_KEY, :NONCE_KEY, :AUTH_SALT,
                                     :SECURE_AUTH_SALT, :LOGGED_IN_SALT,
                                     :NONCE_SALT]

      WP_CONFIGURATION_ALL        = WP_CONFIGURATION_ATTRIBUTES +
                                    WP_CONFIGURATION_SALTS

      ##
      # Define the behaviours of the default parameters quickly
      def method_missing(meth, *args, &block)
        # Convert the method to a symbol
        method_symbol = meth.to_sym

        if WP_CONFIGURATION_ATTRIBUTES.include? method_symbol
          return @environment[meth.to_s] if @environment.has_key? meth.to_s
          ""
        elsif WP_CONFIGURATION_SALTS.include? method_symbol
          # Return salt if the method is a salting method
          Configuration.salt
        else
          # You *must* call super if you don't handle the method, otherwise
          # you will mess up Ruby's method lookup.
          super
        end
      end

      ##
      # Define respond_to?
      def respond_to?(method)
        return true if WP_CONFIGURATION_ALL.include? method.to_sym
        super
      end

      private

      ##
      # The Salting array
      # Provides the array of available characters that can bet used as salt
      def self.salt_array
        @salt_array ||= %w{0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ! @ # $ % ^ & * ( ) - ~ + = | / { } : ; , . ? < > [ ]}
      end

      def define(key, value)
        "define('#{key}', '#{value}');"
      end

    end

  end
end
