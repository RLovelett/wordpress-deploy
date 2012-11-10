module WordpressDeploy
  class Environment

    attr_reader :name

    def initialize(name, store = true, &block)
      @name = name
      @base_url ||= "localhost"
      @wplang   ||= ""
      @wpdebug  ||= false

      # Get an Erb template
      @template = ERB.new(File.read(File.join(WordpressDeploy::TEMPLATE_PATH, "wp-config.erb")))
      @output   = Environment.output_file

      instance_eval(&block) if block_given?

      Environments << self if store
    end

    ##
    # This is the url to search the the database for.
    def base_url(new_base = nil)
      @base_url = new_base.to_s unless new_base.nil?
      @base_url
    end

    ##
    # Provide the database configuration for the environment
    #
    # Returns an instance
    #
    def database(&block)
      @database_config ||= WordpressDeploy::Database::Environment.new
      @database_config.instance_eval(&block) if block_given?
      @database_config.base_url base_url
      @database ||= WordpressDeploy::Database::MySql.new(@database_config)
      @database
    end

    ##
    #
    def salts(&block)
      @salts ||= WordpressDeploy::Wordpress::Salts.new
      @salts.instance_eval(&block) if block_given?
      @salts
    end

    ##
    #
    def transfer(type = nil, &block)
      unless type.nil?
        klass = get_class_from_scope(WordpressDeploy::Storage, type)
        @transfer ||= klass.new
        @transfer.instance_eval(&block) if block_given?
      end
      @transfer
    end

    ##
    # Write the file the filesystem
    def save_wp_config
      # Remove the output file if is already there
      FileUtils.rm @output if File.exists? @output

      # Open the output file
      File.open(@output, 'w') do |f|
        # Evaluate the ERB template
        f.write @template.result(get_binding)
      end
    end

    ##
    #
    def wplang(new_wp_lang = nil)
      @wplang = new_wp_lang.to_s unless new_wp_lang.nil?
      @wplang
    end

    ##
    #
    def wpdebug(new_wp_debug = nil)
      # Only assign if argument is a boolean value
      # http://stackoverflow.com/questions/3028243/check-if-ruby-object-is-a-boolean
      @wpdebug = new_wp_debug if (new_wp_debug.is_a?(TrueClass) || new_wp_debug.is_a?(FalseClass))
      @wpdebug.to_s
    end

    private

    def self.output_file
      File.expand_path(File.join(Config.wp_dir, "wp-config.php"))
    end

    ##
    # Used for ERB generation
    def get_binding
      binding
    end

    ##
    # Returns the class/model specified by +name+ inside of +scope+.
    # +scope+ should be a Class/Module.
    # +name+ should be a Symbol representation of any namespace which exists
    # under +scope+.
    #
    # Examples:
    #   get_class_from_scope(DaavTest::Executables, :Pioneer3)
    #     returns the class DaavTest::Executables::Pioneer3
    def get_class_from_scope(scope, name)
      scope.const_get(name)
    end

  end
end
