module WordpressDeploy
  ##
  # Config defines all of the locations of input and
  # output files. Specifically, the locations of the test
  # definitions, the locations of the test results, and
  # the locations of the build applications.
  module Config

    ##
    # Setup required paths based on the given options
    def self.set_options(options = {})
      options.each do |option, value|
        method = "#{option}="
        send(method, value) if respond_to? method and !value.empty?
      end
    end

    def self.logging=(new_log)
      # Only set @@logging if new_log is a boolean
      if !!new_log == new_log
        @@logging = new_log
      else
        @@logging = false
      end
    end

    def self.logging?
      @@logging ||= false
      @@logging
    end

    def self.root_dir=(new_root)
      @@root_dir = new_root
    end

    def self.root_dir
      @@root_dir ||= Dir.pwd
      File.expand_path @@root_dir
    end

    def self.config_dir=(new_config_dir)
      @@config_dir = new_config_dir
    end

    def self.config_dir
      @@config_dir ||= "config"
      File.expand_path File.join(root_dir, @@config_dir)
    end

    def self.wp_dir=(new_wp_dir)
      @@wp_dir = new_wp_dir
    end

    def self.wp_dir
      @@wp_dir ||= "site"
      File.expand_path File.join(root_dir, @@wp_dir)
    end

    def self.log_file
      @@log_file ||= "#{Time.now.strftime("%Y_%m_%d_%H_%M_%S")}.log"
      File.expand_path File.join(root_dir, @@log_file)
    end

    def self.clean!
      FileUtils.rm Dir.glob(File.join(root_dir, "*.log"))
    end
  end
end
