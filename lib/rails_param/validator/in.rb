module RailsParam
  class Validator
    class In < Validator
      def valid_value?
        value.nil? || case options[:in]
                      when Range
                        options[:in].include?(value)
                      else
                        Array(options[:in]).include?(value)
                      end
      end

      private

      def error_message
        "Parameter #{parameter.name} must be within #{parameter.options[:in]}"
      end
    end
  end
end
