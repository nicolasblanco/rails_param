module RailsParam
  module ErrorMessages
    class IsRequiredMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} is required"
      end
    end
  end
end