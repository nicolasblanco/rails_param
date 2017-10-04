module RailsParam
  module ErrorMessages
    class MustBeEqualMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} must be #{value}"
      end
    end
  end
end