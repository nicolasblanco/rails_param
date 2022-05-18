module RailsParam
  class Validator
    class Required < Validator
      private

      def valid_value?
        !(value.nil? && options[:required])
      end

      def error_message
        I18n.t(
          "#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.required",
          name: name
        )
      end
    end
  end
end
