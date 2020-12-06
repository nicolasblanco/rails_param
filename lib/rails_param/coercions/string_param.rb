module RailsParam
  module Param
    class StringParam
      attr_reader :param, :options, :type

      def initialize(param:, options: nil, type: nil)
        @param, @options, @type = param, options, type
      end

      def coerce
        String(param)
      end
    end
  end
end
