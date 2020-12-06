module RailsParam
  module Param
    class FloatParam
      attr_reader :param, :options, :type

      def initialize(param:, options: nil, type: nil)
        @param, @options, @type = param, options, type
      end

      def coerce
        Float(param)
      end
    end
  end
end
