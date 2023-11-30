module RailsParam
  class Validator
    class Format < Validator
      def valid_value?
        matches_time_types? || string_in_format?
      end

      private

      TIME_TYPES = [Date, DateTime, Time].freeze
      STRING_OR_TIME_TYPES = ([String] + TIME_TYPES).freeze

      def error_type
        :invalid_string_or_time unless matches_string_or_time_types?
        :invalid_string_format unless string_in_format?
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

      # because format is reserved keyword in i18n and raise ReservedInterpolationKey
      def error_message
        I18n.t("rails_param.errors.#{error_type}",
               **options.merge({ name: name, value: value, format_pattern: options[:format] }))
      end
    end
  end
end
