module RailsParam
  class Validator
    class MaxLength < Validator
      def valid_value?
        value.nil? || options[:max_length] >= value.length
      end
    end
  end
end
