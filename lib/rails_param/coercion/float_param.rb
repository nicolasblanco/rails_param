module RailsParam
  class Coercion
    class FloatParam < VirtualParam
      def coerce
        return nil if param == '' # e.g. from an empty field in an HTML form

        Float(param)
      end
    end
  end
end
