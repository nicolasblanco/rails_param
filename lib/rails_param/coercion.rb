module RailsParam
  module Param
    class Coercion
      attr_reader :coercion, :param

      TIME_TYPES = [Date, DateTime, Time].freeze
      BOOLEAN_TYPES = [TrueClass, FalseClass, :boolean].freeze

      def initialize(param, type, options)
        @param = param
        @coercion = klass_for(type).new(param: param, options: options, type: type)
      end

      def klass_for(type)
        if (param.is_a?(Array) && type != Array) || ((param.is_a?(Hash) || param.is_a?(ActionController::Parameters)) && type != Hash)
          raise ArgumentError
        end

        return IntegerParam if type == Integer
        return FloatParam if type == Float
        return StringParam if type == String
        return ArrayParam if type == Array
        return TimeParam if TIME_TYPES.include? type
        return HashParam if type == Hash
        return BooleanParam if BOOLEAN_TYPES.include? type
        return BigDecimalParam if type == BigDecimal

        raise TypeError
      end

      def coerce
        coercion.coerce
      end
    end
  end
end