module RailsParam
  module ErrorMessages
    class MustBeAStringMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} must be a string if using the format validation"
      end
    end
  end
end