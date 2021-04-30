module RailsParam
  class Coercion
    class VirtualParam
      attr_reader :param, :options, :type

      def initialize(param:, options: nil, type: nil)
        @param = param
        @options = options
        @type = type
        argument_validation
      end

      def coerce
        nil
      end

      private

      def argument_validation
        nil
      end
    end
  end
end
