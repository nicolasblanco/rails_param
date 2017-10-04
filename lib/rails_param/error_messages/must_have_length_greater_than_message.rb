module RailsParam
  module ErrorMessages
    class MustHaveLengthGreaterThanMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} cannot have length greater than #{value}"
      end
    end
  end
end