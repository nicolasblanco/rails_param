module RailsParam
  class Validator
    class Min < Validator
      def valid_value?
        value.nil? || options[:min] <= value
      end

      private

      def error_message
        "Parameter #{name} cannot be less than #{options[:min]}"
      end
    end
  end
end
