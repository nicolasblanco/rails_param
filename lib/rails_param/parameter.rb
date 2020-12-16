module RailsParam
  module Param
    class Parameter
      attr_accessor :name, :value, :options, :type

      TIME_TYPES = [Date, DateTime, Time].freeze
      STRING_OR_TIME_TYPES = ([String] + TIME_TYPES).freeze

      def initialize(name:, value:, options: nil, type: nil)
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
            raise InvalidParameterError, "Parameter #{name} is required" if v && value.nil?
          when :blank
            raise InvalidParameterError, "Parameter #{name} cannot be blank" if !v && case value
                                                                                    when String
                                                                                      !(/\S/ === value)
                                                                                    when Array, Hash, ActionController::Parameters
                                                                                      value.empty?
                                                                                    else
                                                                                      value.nil?
                                                                                  end
          when :format
            raise InvalidParameterError, "Parameter #{name} must be a string if using the format validation" unless STRING_OR_TIME_TYPES.any? { |cls| value.kind_of? cls }
            raise InvalidParameterError, "Parameter #{name} must match format #{v}" if value.kind_of?(String) && value !~ v
          when :is
            raise InvalidParameterError, "Parameter #{name} must be #{v}" unless value === v
          when :in, :within, :range
            raise InvalidParameterError, "Parameter #{name} must be within #{v}" unless value.nil? || case v
                                                                                                    when Range
                                                                                                      v.include?(value)
                                                                                                    else
                                                                                                      Array(v).include?(value)
                                                                                                  end
          when :min
            raise InvalidParameterError, "Parameter #{name} cannot be less than #{v}" unless value.nil? || v <= value
          when :max
            raise InvalidParameterError, "Parameter #{name} cannot be greater than #{v}" unless value.nil? || v >= value
          when :min_length
            raise InvalidParameterError, "Parameter #{name} cannot have length less than #{v}" unless value.nil? || v <= value.length
          when :max_length
            raise InvalidParameterError, "Parameter #{name} cannot have length greater than #{v}" unless value.nil? || v >= value.length
          when :custom
            v.call(value)
          end
        end
      end

      private

      def check_param_presence? param
        !param.nil?
      end
    end
  end
end