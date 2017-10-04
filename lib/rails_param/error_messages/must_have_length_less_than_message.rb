module RailsParam
  module ErrorMessages
    class MustHaveLengthLessThanMessage < RailsParam::ErrorMessages::BaseMessage
      def to_s
        "Parameter #{param_name} cannot have length less than #{value}"
      end
    end
  end
end