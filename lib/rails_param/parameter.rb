module RailsParam
  module Param
    class Parameter
      attr_accessor :value, :options

      def initialize(value:, options: nil)
        @value = value
        @options = options
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

      private

      def check_param_presence? param
        !param.nil?
      end
    end
  end
end