module RailsParam
  module Param
    class Validator
      class MaxLength < Validator
        def valid_value?
          value.nil? || options[:max_length] >= value.length
        end

        private

        def error_message
          "Parameter #{name} cannot have length greater than #{options[:max_length]}"
        end
      end
    end
  end
end
