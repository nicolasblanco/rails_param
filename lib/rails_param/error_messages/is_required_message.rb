module RailsParam
  module ErrorMessages
    class IsBlankMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} cannot be blank"
      end
    end
  end
end