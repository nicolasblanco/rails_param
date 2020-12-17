module RailsParam
  module Param
    class Parameter
      attr_accessor :name, :value, :options, :type

      TIME_TYPES = [Date, DateTime, Time].freeze
      STRING_OR_TIME_TYPES = ([String] + TIME_TYPES).freeze

      def initialize(name:, value:, options: {}, type: nil)
        @name = name
        @value = value
        @options = options
        @type = type
      end

      def should_set_default?
        value.nil? && check_param_presence?(options[:default])
      end

      def set_default
        self.value = options[:default].respond_to?(:call) ? options[:default].call : options[:default]
      end

      def transform
        self.value = options[:transform].to_proc.call(value)
      end

      def validate
        options.each do |k, v|
          case k
          when :required
            Validator.new(self).validate!
          when :blank
            Validator.new(self).validate!
          when :format
            Validator.new(self).validate!
          when :is
            Validator.new(self).validate!
          when :in, :within, :range
            Validator.new(self).validate!
          when :min
            Validator.new(self).validate!
          when :max
            Validator.new(self).validate!
          when :min_length
            Validator.new(self).validate!
          when :max_length
            Validator.new(self).validate!
          when :custom
            Validator.new(self).validate!
          end
        end
      end

      private

      def check_param_presence?(param)
        !param.nil?
      end
    end
  end
end
