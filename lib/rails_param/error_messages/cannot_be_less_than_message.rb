module RailsParam
  module ErrorMessages
    class CannotBeLessThanMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} cannot be less than #{value}"
      end
    end
  end
end