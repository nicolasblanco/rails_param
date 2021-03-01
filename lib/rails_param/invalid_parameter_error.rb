module RailsParam
  module Param
    class InvalidParameterError < StandardError
      attr_accessor :param, :options

      def message
        return options[:message] if options.is_a?(Hash) && options.key?(:message)

        super
      end
    end
  end
end
