module RailsParam
  class Validator
    class Blank < Validator
      def valid_value?
        return false if parameter.options[:blank]

        case value
        when String
          (/\S/ === value)
        when Array, Hash, ActionController::Parameters
          !value.empty?
        else
          !value.nil?
        end
      end

      private

      def error_message
        I18n.t(
          "#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.blank",
          name: name
        )
      end
    end
  end
end
