module RailsParam
  module Param
    class InvalidParameterError < StandardError
      attr_accessor :param, :options

      def initialize(message, param: nil, options: {})
        self.param = param
        self.options = options
        super(message)
      end

      def message
        return options[:message] if options.is_a?(Hash) && options.key?(:message)

        super
      end
    end
  end
end
