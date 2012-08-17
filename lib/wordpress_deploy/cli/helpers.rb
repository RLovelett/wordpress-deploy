# encoding: utf-8

module WordpressDeploy
  module Cli
    module Helpers
      UTILITY = {}

      ##
      # Runs a system command
      #
      # All messages generated by the command will be logged.
      # Messages on STDERR will be logged as warnings.
      #
      # If the command fails to execute, or returns a non-zero exit status
      # an Error will be raised.
      #
      # Returns nil
      def run(command)
        name = command_name(command)
        Logger.debug "Running system utility '#{ name }'..."

        begin
          out, err, ps = '', '', nil
          Open3.popen3 command do |stdin, stdout, stderr, wait_thr|
            stdin.close
            out = stdout.read.strip
            err = stderr.read.strip
            ps = wait_thr.value #Process::Status object returned
          end
        rescue Exception => e
          raise Errors::Cli::SystemCallError.wrap(e, <<-EOS)
            Failed to execute system command on #{ RUBY_PLATFORM }
            Command was: #{ command }
          EOS
        end

        if !ps.nil? && ps.success?
          unless out.empty?
            Logger.debug(
              out.lines.map {|line| "#{ name }:STDOUT: #{ line }" }.join
            )
          end

          unless err.empty?
            Logger.warn(
              err.lines.map {|line| "#{ name }:STDERR: #{ line }" }.join
            )
          end

          return nil
        else
          raise Errors::Cli::SystemCallError, <<-EOS
            '#{ name }' Failed on #{ RUBY_PLATFORM }
            The following information should help to determine the problem:
            Command was: #{ command }
            Exit Status: #{ ps.exitstatus }
            STDOUT Messages: #{ out.empty? ? 'None' : "\n#{ out }" }
            STDERR Messages: #{ err.empty? ? 'None' : "\n#{ err }" }
          EOS
        end
      end


      ##
      # Returns the full path to the specified utility.
      # Raises an error if utility can not be found in the system's $PATH
      def utility(name)
        name = name.to_s.strip
        raise Errors::Cli::UtilityNotFoundError,
            'Utility Name Empty' if name.empty?

        # Return the utility immediately if it has already been found
        path = UTILITY[name]
        return path unless path.nil?

        err, ps = '', nil
        Open3.popen3 "which #{name}" do |stdin, stdout, stderr, wait_thr|
          stdin.close
          path = stdout.read.strip.chomp
          err  = stderr.read.strip.chomp

          # Process::Status object returned
          ps = wait_thr.value
        end

        if !ps.nil? && ps.success?
          UTILITY[name] = path
        else
          raise Errors::Cli::UtilityNotFoundError, <<-EOS
            Could not locate '#{ name }'.
            Make sure the specified utility is installed
            and available in your system's $PATH.
          EOS
        end
      end

      ##
      # Returns the name of the command name from the given command line
      def command_name(command)
        i = command =~ /\s/
        command = command.slice(0, i) if i
        command.split('/')[-1]
      end

    end
  end
end
