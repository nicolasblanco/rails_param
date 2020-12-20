module RailsParam
  module Param
    class Coercion
      class BigDecimalParam
        attr_accessor :param, :options, :type

        DEFAULT_PRECISION = 14

        def initialize(param:, options: nil, type: nil)
          @param = param
          @options = options
          @type = type
        end

        def coerce
          stripped_param = if param.is_a?(String)
                             param.delete('$,').strip.to_f
                           else
                             param
                           end

          BigDecimal(stripped_param, options[:precision] || DEFAULT_PRECISION)
        end
      end
    end
  end
end
