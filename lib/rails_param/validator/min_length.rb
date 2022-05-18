module RailsParam
  class Validator
    class MinLength < Validator
      def valid_value?
        value.nil? || options[:min_length] <= value.length
      end

      private

      def error_message
        I18n.t(
          "#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.min_length",
          name: name,
          options: options[:min_length]
        )
      end
    end
  end
end
