module RailsParam
  module Param
    class Validator
      class Required < Validator
        def valid_value?
          !value.nil? && options[:required]
        end

        private

        def error_message
          "Parameter #{name} is required"
        end
      end
    end
  end
end
