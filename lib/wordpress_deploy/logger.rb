# encoding: utf-8
require 'colorize'

module WordpressDeploy
  module Logger
    class << self

      attr_accessor :verbose

      # Outputs the data as if it were a regular 'puts' command,
      # but also logs it to the backup.log
      def normal(string, color = nil)
        string = string.colorize(color) unless color.nil?
        to_console  loggify(string)
        to_file     loggify(string)
      end

      ##
      # Outputs a debug message to the console and writes it to the
      # backup.log
      def debug(string, color = nil)
        string = string.colorize(color) unless color.nil?
        to_console  loggify(string, :debug, :blue) if verbose
        to_file     loggify(string, :debug)
      end

      ##
      # Outputs a notice to the console and writes it to the backup.log
      # Sets #has_warnings? true so :on_warning notifications will be sent
      def warn(string, color = nil)
        @has_warnings = true
        string = string.colorize(color) unless color.nil?
        to_console  loggify(string, :warning, :yellow), true
        to_file     loggify(string, :warning)
      end

      ##
      # Outputs an error to the console and writes it to the backup.log
      # Called when an Exception has caused the backup process to abort.
      def error(string, color = nil)
        string = string.colorize(color) unless color.nil?
        to_console  loggify(string, :error,   :red), true
        to_file     loggify(string, :error)
      end

      ##
      # Silently logs data to the log file
      def silent(string)
        to_file     loggify(string, :silent)
      end

      ##
      # Returns an Array of all messages written to the log file for this session
      def messages
        @messages ||= []
      end

      ##
      # Returns true if any warnings have been issued
      def has_warnings?
        @has_warnings ||= false
      end

      def clear!
        messages.clear
        @has_warnings = false
      end

      def truncate!(max_bytes = 500_000)
        log_file = Config.log_file
        return unless File.exist?(log_file)

        if File.stat(log_file).size > max_bytes
          FileUtils.mv(log_file, log_file + '~')
          File.open(log_file + '~', 'r') do |io_in|
            File.open(log_file, 'w') do |io_out|
              io_in.seek(-max_bytes, IO::SEEK_END) && io_in.gets
              while line = io_in.gets
                io_out.puts line
              end
            end
          end
          FileUtils.rm_f(log_file + '~')
        end
      end

      private

      ##
      # Returns the time in [YYYY/MM/DD HH:MM:SS] format
      def time
        Time.now.strftime("%Y/%m/%d %H:%M:%S")
      end

      ##
      # Receives a String, or an Object that responds to #to_s (e.g. an
      # Exception), from one of the messaging methods and converts it into an
      # Array of Strings, split on newline separators. Each line is then
      # formatted into a log format based on the given options, and the Array
      # returned to be passed to to_console() and/or to_file().
      def loggify(string, type = false, color = false)
        lines = string.to_s.split("\n")
        if type
          type = type.to_s.colorize(color) if color
          time_now = time
          lines.map {|line| "[#{time_now}][#{type}] #{line}" }
        else
          lines
        end
      end

      ##
      # Receives an Array of Strings to be written to the console.
      def to_console(lines, stderr = false)
        lines.each {|line| stderr ? Kernel.warn(line) : puts(line) }
      end

      ##
      # Receives an Array of Strings to be written to the log file.
      def to_file(lines)
        dir_name = File.dirname(Config.log_file)
        File.open(Config.log_file, 'a') do |file|
          lines.each {|line| file.puts line }
        end if File.writable? dir_name
        messages.push(*lines)
      end

    end
  end
end
