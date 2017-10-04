module RailsParam
  module ErrorMessages
    class CannotBeGreaterThanMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} cannot be greater than #{value}"
      end
    end
  end
end