module RailsParam
  module Param
    class Validator
      class Required < Validator
        def valid_value?
          !parameter.value.nil? && parameter.options[:required]
        end

        private

        def error_message
          "Parameter #{parameter.name} is required"
        end
      end
    end
  end
end
