module RailsParam
  class Validator
    class MinLength < Validator
      def valid_value?
        value.nil? || options[:min_length] <= value.length
      end
    end
  end
end
