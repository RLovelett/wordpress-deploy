module WordpressDeploy
  module Wordpress
    class Salts

      @@keys = [
        :@auth_key, :@secure_auth_key, :@logged_in_key,
        :@nonce_key, :@auth_salt, :@secure_auth_salt,
        :@logged_in_salt, :@nonce_salt
      ]

      def initialize(&block)
        ##
        # Create initial values for all the salts
        @@keys.each { |key| instance_variable_set(key, Salts.salt) }

        instance_eval(&block) if block_given?
      end

      ##
      # Returns 64 psuedo-random characters as a string
      # Characters can be a-zA-z or !@#$%^&*()-~+=|/{}:;,.?<>[]
      def self.salt
        salt_array.sample(64).join("")
      end

      ##
      # Respond with the named configuration if the method name is a
      # a valid configuration that has been loaded.
      def method_missing(method, *args, &block)
        instance_variable = "@#{method.to_s}".to_sym

        if @@keys.include? instance_variable
          args.flatten!
          # Set the instance variable to the value passed in
          unless args.empty?
            instance_variable_set(instance_variable, args[0])
          end

          # Return the value of the instance_variable
          instance_variable_get(instance_variable)
        else
          super
        end
      end

      ##
      # Respond to an configuration name as though it is a method.
      def respond_to?(method)
        instance_variable = "@#{method.to_s}".to_sym
        return true if @@keys.include? instance_variable
        super
      end

      private

      def is_a_key?(potential_key)
      end

      ##
      # The Salting array
      # Provides the array of available characters that can bet used as salt
      def self.salt_array
        @salt_array ||= %w{0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ! @ # $ % ^ & * ( ) - ~ + = | / { } : ; , . ? < > [ ]}
      end

    end
  end
end
