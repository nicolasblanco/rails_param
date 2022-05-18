module RailsParam
  class Validator
    class Max < Validator
      def valid_value?
        value.nil? || options[:max] >= value
      end

      private

      def error_message
        I18n.t(
          "#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.max",
          name: name,
          options: options[:max]
        )
      end
    end
  end
end
