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


      desc "generate", "Generate the wp-config.php file."
      def generate(environment)
        ##
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Environment.set_options options

        # Create a configuration file
        config = Wordpress::Configuration.new environment

        # Save the configuration file
        config.save!
      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      end

      desc "deploy", "Deploy via FTP to configuration hostname."
      def deploy(environment)
        ##
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Environment.set_options options

        # Create a new FTP client for sending the files
        ftp_client = TransferProtocols::Ftp.new environment

        # Now transmit the files
        ftp_client.transmit!

      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      ensure
        puts "Closing connection.".colorize(color: :red, background: :yellow) if ftp_client.close
      end

      desc "backup", "Pull down the remote files over FTP."
      def backup(environment)
        ##
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Environment.set_options options

        # Create a new FTP client for receiving the files
        ftp_client = TransferProtocols::Ftp.new environment

        # Now receive the files
        ftp_client.receive!

      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      ensure
        puts "Closing connection.".colorize(color: :red, background: :yellow) if ftp_client.close
      end

      desc "mirror", "Mirror database between two locations"
      def mirror(from, to)
        ##
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Environment.set_options options

        # Save the 'from' database to the SQL directory
        from_mysql = Database::MySql.new from
        from_mysql.save!

        # Send the 'from' database to the 'to' database
        from_mysql.send! to

        # Migrate the to database now on the 'to' database
        # to have the proper strings and such
        from_mysql.migrate! to
      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      end
    end
  end
end

