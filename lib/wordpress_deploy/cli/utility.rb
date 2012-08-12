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
      class_option :environment, type: :string,  default: 'production', aliases: '-e'
      class_option :verbose,     type: :boolean, default: false,        aliases: '-v'


      desc "generate", "Generate the wp-config.php file. Accepted environments are production or development."
      def generate
        ##
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Environment.set_options options

        # Create a configuration file
        config = Wordpress::Configuration.new

        # Save the configuration file
        config.save!
      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      end

      desc "deploy", "Deploy via FTP to configuration hostname."
      def deploy
        ##
        # Set Logger into verbose mode (if the user requested it)
        Logger.verbose = options[:verbose]

        # Set environment options
        Environment.set_options options

        # Create a new FTP client for sending the files
        ftp_client = TransferProtocols::Ftp.new options[:environment]

        # Now transmit the files
        ftp_client.transmit!

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
      rescue => err
        Logger.error Errors::Cli::Utility::Error.wrap(err)

        # Exit with an error
        exit(1)
      end
    end
  end
end

