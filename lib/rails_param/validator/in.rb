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
    end
  end
end
