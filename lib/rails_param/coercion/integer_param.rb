module RailsParam
  class Coercion
    class IntegerParam < VirtualParam
      def coerce
        return nil if param == '' # e.g. from an empty field in an HTML form

        Integer(param)
      end
    end
  end
end
