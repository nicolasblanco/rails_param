module RailsParam
  class Validator
    class Max < Validator
      def valid_value?
        value.nil? || options[:max] >= value
      end
    end
  end
end
