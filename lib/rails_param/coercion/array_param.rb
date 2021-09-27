module RailsParam
  class Coercion
    class ArrayParam < VirtualParam
      def coerce
        return [] if param.nil?
        return param if param.is_a?(Array)

        Array(param.split(options[:delimiter] || ","))
      end

      private

      def argument_validation
        raise ArgumentError unless type == Array

        return if param.nil? || param.respond_to?(:split)

        raise ArgumentError
      end
    end
  end
end
