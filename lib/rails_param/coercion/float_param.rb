module RailsParam
  class Coercion
    class FloatParam < VirtualParam
      def coerce
        Float(param)
      end
    end
  end
end
