module RailsParam
  module Param
    class ArrayParam
      attr_reader :param, :options, :type

      def initialize(param:, options: nil, type: nil)
        @param, @options, @type = param, options, type
      end

      def coerce
        raise ArgumentError unless param.respond_to?(:split)

        Array(param.split(options[:delimiter] || ","))
      end
    end
  end
end
