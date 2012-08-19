module WordpressDeploy
  module Storage
    class Local

      def destination(new_dest = nil)
        @destination = new_dest.to_s unless new_dest.nil?
        @destination
      end

    end
  end
end
