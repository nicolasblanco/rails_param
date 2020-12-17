module RailsParam
  module Param
    class Validator
      class Is < Validator
        def valid_value?
          parameter.value === parameter.options[:is]
        end

        private

        def error_message
          "Parameter #{parameter.name} must be #{parameter.options[:is]}"
        end
      end
    end
  end
end
