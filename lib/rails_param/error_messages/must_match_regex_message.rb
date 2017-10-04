module RailsParam
  module ErrorMessages
    class MustMatchRegexMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} must match format #{value}"
      end
    end
  end
end