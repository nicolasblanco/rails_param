require 'forwardable'

module RailsParam
  module Param
    class Validator
      extend Forwardable

      attr_reader :parameter

      def_delegators :parameter, :name, :options, :value

      VALIDATABLE_OPTIONS = [
        :blank,
        :custom,
        :format,
        :in,
        :is,
        :max_length,
        :max,
        :min_length,
        :min,
        :required
      ].freeze

      def initialize(parameter)
        @parameter = parameter
      end

      def validate!
        options.each_key do |key|
          next unless VALIDATABLE_OPTIONS.include? key

          class_name = camelize(key)
          Validator.const_get(class_name).new(parameter).valid!
        end
      end

      def valid!
        raise InvalidParameterError, error_message unless valid_value?

      rescue InvalidParameterError => exception
        exception.param ||= name
        exception.options ||= options
        raise exception
      end

      private

      def camelize(term)
        string = term.to_s
        string.split('_').collect(&:capitalize).join
      end

      def error_message
        nil
      end

      def valid_value?
        # Should be overwritten in subclass
        false
      end
    end
  end
end
