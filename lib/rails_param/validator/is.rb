module RailsParam
  class Validator
    class Is < Validator
      def valid_value?
        value === options[:is]
      end
    end
  end
end
