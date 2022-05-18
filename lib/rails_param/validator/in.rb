module RailsParam
  class Validator
    class In < Validator
      def valid_value?
        value.nil? || case options[:in]
                      when Range
                        options[:in].include?(value)
                      else
                        Array(options[:in]).include?(value)
                      end
      end

      private

      def error_message
        I18n.t(
          "#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.in",
          name: parameter.name, options: parameter.options[:in]
        )
      end
    end
  end
end
