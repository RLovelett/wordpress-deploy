
module WordpressDeploy
  module Environments

  class << self

    ##
    # Load the environment files in the configuration directory.
    def load
      files = Dir[File.join(WordpressDeploy::Config.config_dir, "**/*.rb")]
      files.each { |file| require file }
      nil
    end

    ##
    # Add a new environment. If the environment name is already in use
    # it is not added.
    #
    # Return the number of configurations currently loaded.
    def <<(*environments)
      environments.flatten!
      environments.each do |env|
        env_name = (env.respond_to? :name) ? env.name : nil
        envs << env unless name? env_name
      end
      envs.count
    end

    ##
    # Test if the name is a valid Configuration name.
    #
    # Return true if it is; false otherwise.
    def name?(name)
      name_to_find = name.to_sym
      !envs.index { |env| env.name === name_to_find }.nil?
    end

    ##
    #
    def find(name)
      name_to_find = name.to_sym
      index = envs.index { |env| env.name === name_to_find }
      raise Exception,
            "#{name} is not a valid environment" if index.nil?
      envs[index]
    end

    ##
    # Return an array of the available configuration symbol names.
    def names
      envs.map { |config| config.name }
    end
    alias :available_names :names

    ##
    # Respond with the named configuration if the method name is a
    # a valid configuration that has been loaded.
    def method_missing(method, *args, &block)
      if name?(method.to_sym)
        find(method.to_sym)
      else
        super
      end
    end

    ##
    # Respond to an configuration name as though it is a method.
    def respond_to?(method)
      return true if name?(method.to_sym)
      super
    end

    private

    ##
    # Create a private instance variable @configurations
    # if one has not already been defined.
    #
    # Return the @configurations variable.
    def envs
      @envs ||= []
      @envs
    end

  end

  end

end
