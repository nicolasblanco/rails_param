module RailsParam
  module ErrorMessages
    class MustBeWithinMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} must be within #{value}"
      end
    end
  end
end