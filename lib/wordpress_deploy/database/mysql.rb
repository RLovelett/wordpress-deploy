require 'tempfile'
require 'sequel'
require 'mysql2'
require 'php_serialize'
require 'shellwords'

module WordpressDeploy
  module Database

    class MySql
      include WordpressDeploy::Cli::Helpers

      attr_reader :env, :errors
      alias :environment :env

      def initialize(environment)
        @env = environment
        @db = Sequel.mysql(
          adapter: "mysql2",
          host:     @env.host,
          user:     @env.user,
          password: @env.password,
          port:     @env.port,
          database: @env.name,
          encoding: @env.charset
        )
        @errors = []
        @transactions = []
      end

      ##
      # Test the connection to the database defined by this environment. It
      # returns true if a connection can be made; false otherwise.
      def connection?
        @db.test_connection
      rescue
        false
      end

      ##
      # Save the database to a file locally.
      #
      # The database will be output into #file.
      def save!
        # Get the output from MySQL Dump
        cmd = mysqldump
        dump_str = run cmd

        # Open the supplied file; or create a temporary one
        file_io = File.new(env.file, 'w')

        # Start writing to file
        file_io.write(dump_str)

        true
      ensure
        file_io.close unless file_io.nil?
      end

      ##
      #
      def send!(to_env)
        # Get the MySql instance
        to_db = to_env.database

        # Check to see if there is a SQL file
        if File.exists? file
          tmp_file = Tempfile.new(["#{to_db.name}", '.sql'])

          # Open the source sql file for reading
          sql_dump = File.read(file)

          # Write sql to tmpfile while changing the
          # the CREATE DATABASE and USE commands to make sense for
          # the 'to' configuration
          sql_dump.gsub!(/^CREATE\ DATABASE.*$/i, "")
          sql_dump.gsub!(/^USE\ `#{name}`/, "USE `#{to_db.name}`")
          tmp_file.puts sql_dump

          # Get the MySQL load command
          cmd = mysqlload to_db, tmp_file.path

          # Run the mysql command to load the mysqldump into
          # the destination mysql instance
          run cmd
        end
      ensure
        # Delete the temp file unless it was never made
        tmp_file.unlink unless tmp_file.nil?
      end

      ##
      # Find and replace a string in the database.
      #
      # The first argument is the value to find and the second
      # the value the found argument will be replaced with.
      #
      # Searches all tables in the database. The search is performed
      # against all columns excluding the primary key.
      def migrate!(value_to_find, value_to_replace)
        raise "MySQL: #{env.name} is unreachable on #{env.wp_host}." unless connection?

        # Begin searching each table
        @db.tables.each do |table|

          # Now get the tables schema
          schema = @db.schema(table)

          # Select the primary key for the table
          primary_key = schema.map { |column| column[0] if     column[1][:primary_key] }.compact[0]

          # Get all the columns to search (i.e., everything that is not a primary key)
          columns     = schema.map { |column| column[0] unless column[1][:primary_key] }.compact

          # Loop over each column
          columns.each do |column|

            # Create the query to search MySQL
            dataset = @db.select(primary_key, column).from(table).where(Sequel.like(column, /#{value_to_find}/))

            # Log the query that is about to be performed
            Logger.debug dataset.select_sql

            # Manipulate each row in the dataset
            dataset.each do |row|
              begin
                value = row[column]
                if PHP.serialized?(value)
                  ruby_php = PHP.unserialize(value)
                  ruby_php.find_and_replace!(value_to_find, value_to_replace)
                  value.replace PHP.serialize(ruby_php)
                elsif value.instance_of?(String)
                  value.gsub!(/#{value_to_find}/, value_to_replace)
                else
                  raise "Cannot handle #{value.class}"
                end

                # Manipulation is over
                row[column] = value

                @transactions << row
              rescue => e
                str = "[#{table}.#{primary_key.to_s} = #{row[primary_key]}] Cannot manipulate column \"#{column.to_s}\". #{e.message}"
                @errors << str
              end
            end

            @db.transaction do
              until @transactions.empty?
                update = @transactions.pop

                # Log the query that is going to be updated
                Logger.debug @db.from(table).where("#{primary_key} = ?", update[primary_key]).update_sql(update)

                # Actually create the update transaction
                @db.from(table).where("#{primary_key} = ?", update[primary_key]).update(update)
              end
            end
          end
        end
      end

      def errors?
        @errors.count > 0
      end

      private

      def mysqldump
        arguments = "-P \"#{env.port}\" -h \"#{env.host}\" -u \"#{env.user}\" -p\"#{Shellwords.escape(env.password)}\" -B \"#{env.name}\""
        "#{utility("mysqldump")} #{arguments}"
      end

      def mysqlload(database, file_name)
        arg_port = database.port
        arg_host = database.host
        arg_user = database.user
        arg_pass = database.password
        arg_name = database.name
        arguments = "-P \"#{arg_port}\" -u \"#{arg_user}\" -h \"#{arg_host}\" -p\"#{Shellwords.escape(arg_pass)}\" -D \"#{arg_name}\""

        "#{utility("mysql")} #{arguments} < #{file_name}"
      end

    end
  end
end

