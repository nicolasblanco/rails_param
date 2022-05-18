module RailsParam
  class Validator
    class Min < Validator
      def valid_value?
        value.nil? || options[:min] <= value
      end

      private

      def error_message
        I18n.t(
          "#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.min",
          name: name,
          options: options[:min]
        )
      end
    end
  end
end
