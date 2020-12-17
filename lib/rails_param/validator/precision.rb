module RailsParam
  module Param
    class Validator
      class Precision < Validator
        def valid_value?
          true
        end

        private

        def error_message
        end
      end
    end
  end
end
