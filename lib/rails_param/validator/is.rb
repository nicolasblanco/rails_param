module RailsParam
  class Validator
    class Is < Validator
      def valid_value?
        value === options[:is]
      end

      private

      def error_message
        "Parameter #{name} must be #{options[:is]}"
      end
    end
  end
end
