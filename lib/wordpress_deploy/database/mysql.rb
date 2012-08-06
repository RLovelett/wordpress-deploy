require 'tmpdir'

module WordpressDeploy
  module Database

    class MySql
      include WordpressDeploy::Cli::Helpers

      private

      def executable_name
        File.expand_path File.join(tmp_dir, "pioneer_app")
      end

      ##
      # A temporary directory for installing the executable to
      def tmp_dir
        @tmp_dir ||= Dir.mktmpdir
        File.expand_path(@tmp_dir)
      end

    end
  end
end

