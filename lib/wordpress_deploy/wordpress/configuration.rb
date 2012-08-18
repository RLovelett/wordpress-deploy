module WordpressDeploy
  module Wordpress

    class Configuration
      include WordpressDeploy::ConfigurationFile

      def initialize(config_name=nil)
        super(config_name)
        @template = File.join(Config.wp_dir, "wp-config-sample.php")
        @output   = File.join(Config.wp_dir, "wp-config.php")
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
