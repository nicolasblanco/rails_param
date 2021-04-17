module RailsParam
  module Param
    class Coercion
      attr_reader :coercion, :param

      PARAM_TYPE_MAPPING = {
        Integer => IntegerParam,
        Float => FloatParam,
        String => StringParam,
        Array => ArrayParam,
        Hash => HashParam,
        BigDecimal => BigDecimalParam,
        Date => TimeParam,
        DateTime => TimeParam,
        Time => TimeParam,
        TrueClass => BooleanParam,
        FalseClass => BooleanParam,
        boolean: BooleanParam
      }.freeze

      TIME_TYPES = [Date, DateTime, Time].freeze
      BOOLEAN_TYPES = [TrueClass, FalseClass, :boolean].freeze

      def initialize(param, type, options)
        @param = param
        @coercion = klass_for(type).new(param: param, options: options, type: type)
      end

      def klass_for(type)
        klass = PARAM_TYPE_MAPPING[type]
        return klass if klass

        raise TypeError
      end

      def coerce
        return nil if param.nil?

        coercion.coerce
      end
    end
  end
end
