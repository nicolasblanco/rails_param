module RailsParam
  class Validator
    class Is < Validator
      def valid_value?
        value === options[:is]
      end

      private

      def error_message
        I18n.t("#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.is",
          name: name, options: options[:is]
        )
      end
    end
  end
end
