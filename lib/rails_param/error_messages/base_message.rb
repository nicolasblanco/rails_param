module RailsParam
  module ErrorMessages
    class BaseMessage
      attr_accessor :param_name, :value

      def initialize(param_name, value = nil)
        @param_name = param_name
        @value = value
      end
    end
  end
end