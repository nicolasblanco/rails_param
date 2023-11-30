module RailsParam
  class Validator
    class Min < Validator
      def valid_value?
        value.nil? || options[:min] <= value
      end
    end
  end
end
