module RailsParam
  class Validator
    class MinLength < Validator
      def valid_value?
        value.nil? || options[:min_length] <= value.length
      end

      private

      def error_message
        "Parameter #{name} cannot have length less than #{options[:min_length]}"
      end
    end
  end
end
