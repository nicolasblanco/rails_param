module RailsParam
  class Coercion
    class StringParam < VirtualParam
      def coerce
        String(param)
      end
    end
  end
end
