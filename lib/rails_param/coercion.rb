require 'pry'
module RailsParam
  class Coercion
    attr_reader :coercion

    TIME_TYPES = [Date, DateTime, Time].freeze
    BOOLEAN_TYPES = [TrueClass, FalseClass, :boolean].freeze

    def initialize(param, type, options)
      @coercion = klass_for(type).new(param: param, options: options, type: type)
    end

    def klass_for(type)
      return IntegerParam if type == Integer
      return FloatParam if type == Float
      return StringParam if type == String
      return ArrayParam if type == Array
      return TimeParam if TIME_TYPES.include? type
      return HashParam if type == Hash
      return BooleanParam if BOOLEAN_TYPES.include? type
      return BigDecimalParam if type == BigDecimal

      # TODO raise something if we get to this nil
      nil
    end

    def coerce
      coercion.coerce
    end
  end
end