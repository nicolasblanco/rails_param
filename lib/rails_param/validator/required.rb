module RailsParam
  class Validator
    class Required < Validator
      private

      def valid_value?
        !(value.nil? && options[:required])
      end
    end
  end
end
