##
# Build the WordpressDeploy Command Line Interface using Thor
#
module WordpressDeploy
  module Cli
    class Utility < Thor
      include Thor::Actions

      # These options apply to all commands
      class_option :root_dir,    type: :string,  default: '',           aliases: '-r'
      class_option :wp_dir,      type: :string,  default: '',           aliases: '-w'
      class_option :config_dir,  type: :string,  default: '',           aliases: '-c'
      class_option :sql_dir,     type: :string,  default: '',           aliases: '-s'
      class_option :verbose,     type: :boolean, default: false,        aliases: '-v'

      desc "config ENVIRONMENT", "Generate the wp-config.php file for the specified environment."
      def config(environment)
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Config.set_options options

        # Load ALL the available environments
        WordpressDeploy::Environments.load

        # Get the Environment the user requested
        env = WordpressDeploy::Environments.find environment.to_sym

        # Save the configuration file
        env.save_wp_config
      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      end

      desc "deploy FROM TO", <<-EOS
Deploy Wordpress onto the TO environment.

This is achieved by first generating the appropriate wp-config.php file for the
desired environment. This wp-config.php, along with all other files within the
wp_dir, are then transmitted to the configured TO environment.

Next, the FROM database is backed up into the sql_dir, and then sent to the
configured TO environment. Finally, all records in the TO database are scrubbed
to be relative to the new hostname configured for the environment (this
includes PHP serialized strings).
      EOS
      def deploy(*env_args)
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Config.set_options options

        # Load ALL the available environments
        WordpressDeploy::Environments.load

        # Map each of the environments. Also, check that the environments exist
        # if an environment was not setup then this needs to die horrifically!
        environments = env_args.map do |arg|
          unless WordpressDeploy::Environments.name?(arg.to_sym)
            raise "The environment #{arg} does not exist. Please check spelling and capitalization"
          end
          WordpressDeploy::Environments.find arg.to_sym
        end

        # Does each environment provide a valid connection to the database? Die
        # horrifically if not!
        environments.each do |env|
          unless env.database.connection?
            Logger.error "Cannot make connection to #{env.name.to_s} database."
            exit(1)
          end
        end

        # Get the Environment the user requested
        from = environments[0]
        to   = environments[1]

        # Save the correct configuration file
        to.save_wp_config

        # Send the files in wp_dir
        to.transfer.transmit!

        # Save the to database locally
        from.database.save!

        # Send the database from => to
        from.database.send!(to)

        # Now manipulate the links in the to database
        to.database.migrate!(from.database.env.base_url, to.database.env.base_url)

        # Display any errors if they are found
        to.database.errors.each do |error|
          Logger.error error
        end

        # Give an failure exit code if there were errors
        exit(1) if to.database.errors?

      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      end

      desc "database FROM TO", "Copy database and manipulate links"
      def database(*env_args)
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Config.set_options options

        # Load ALL the available environments
        WordpressDeploy::Environments.load

        # Map each of the environments. Also, check that the environments exist
        # if an environment was not setup then this needs to die horrifically!
        environments = env_args.map do |arg|
          unless WordpressDeploy::Environments.name?(arg.to_sym)
            raise "The environment #{arg} does not exist. Please check spelling and capitalization"
          end
          WordpressDeploy::Environments.find arg.to_sym
        end

        # Does each environment provide a valid connection to the database? Die
        # horrifically if not!
        environments.each do |env|
          unless env.database.connection?
            Logger.error "Cannot make connection to #{env.name.to_s} database."
            exit(1)
          end
        end

        # Get the Environment the user requested
        from = environments[0]
        to   = environments[1]

        # Save the to database locally
        from.database.save!

        # Send the database to => from
        from.database.send!(to)

        # Now manipulate the links in the to database
        to.database.migrate!(from.database.env.base_url, to.database.env.base_url)

        # Display any errors if they are found
        to.database.errors.each do |error|
          Logger.error error
        end

        # Give an failure exit code if there were errors
        exit(1) if to.database.errors?

      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      end

      desc "backup ENVIRONMENT", "Call mysqldump on the database specified by ENVIRONMENT"
      def backup(environment)
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Config.set_options options

        # Load ALL the available environments
        WordpressDeploy::Environments.load

        # Get the Environment the user requested
        env = WordpressDeploy::Environments.find environment.to_sym

        # Backup the database to the sql_dir
        env.database.save!

      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      end

      desc "transmit ENVIRONMENT", "Transmit the files in wp_dir"
      def transmit(environment)
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Config.set_options options

        # Load ALL the available environments
        WordpressDeploy::Environments.load

        # Get the Environment the user requested
        env = WordpressDeploy::Environments.find environment.to_sym

        # Save the configuration file
        env.save_wp_config

        # Send the files in wp_dir
        env.transfer.transmit!

      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      end
    end
  end
end

