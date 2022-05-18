module RailsParam
  class Validator
    class Format < Validator
      def valid_value?
        matches_time_types? || string_in_format?
      end

      private

      TIME_TYPES = [Date, DateTime, Time].freeze
      STRING_OR_TIME_TYPES = ([String] + TIME_TYPES).freeze

      def error_message
        unless matches_string_or_time_types?
          I18n.t(
            "#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.string_format",
            name: name
          )
        end

        unless string_in_format?
          I18n.t(
            "#{custom_rails_param_i18n_path || default_rails_param_i18n_path}.options_format",
            name: name,
            options: options[:format]
          )
        end
      end

      def matches_time_types?
        TIME_TYPES.any? { |cls| value.is_a? cls }
      end

      def matches_string_or_time_types?
        STRING_OR_TIME_TYPES.any? { |cls| value.is_a? cls }
      end

      def string_in_format?
        value =~ options[:format] && value.kind_of?(String)
      end
    end
  end
end
