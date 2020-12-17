module RailsParam
  module Param
    class Validator
      class Blank < Validator
        def valid_value?
          value = parameter.value
          !(!parameter.options[:blank] &&
            case value
            when String
              !(/\S/ === value)
            when Array, Hash, ActionController::Parameters
              value.empty?
            else
              value.nil?
            end)
        end

        private

        def error_message
          "Parameter #{parameter.name} cannot be blank"
        end
      end
    end
  end
end
