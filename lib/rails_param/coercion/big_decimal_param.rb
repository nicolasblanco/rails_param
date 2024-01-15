module RailsParam
  class Coercion
    class BigDecimalParam < VirtualParam
      DEFAULT_PRECISION = 14

      def coerce
        return nil if param == '' # e.g. from an empty field in an HTML form

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
