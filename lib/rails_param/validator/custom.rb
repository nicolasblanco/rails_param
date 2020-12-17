module RailsParam
  module Param
    class Validator
      class Custom < Validator
        def valid_value?
          !options[:custom].call(value)
        end

        private

        def error_message; end
      end
    end
  end
end
