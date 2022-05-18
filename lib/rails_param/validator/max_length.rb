module RailsParam
  class Validator
    class MaxLength < Validator
      def valid_value?
        value.nil? || options[:max_length] >= value.length
      end

      private

      def error_message
        I18n.t(
          "#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.max_length",
          name: name,
          options: options[:max_length]
        )
      end
    end
  end
end
