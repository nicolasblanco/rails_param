module RailsParam
  class Coercion
    class TimeParam < VirtualParam
      def coerce
        return nil if param == '' # e.g. from an empty field in an HTML form

        return type.strptime(param, options[:format]) if options[:format].present?

        type.parse(param)
      end

      private

      def argument_validation
        raise ArgumentError unless type.respond_to?(:parse)
      end
    end
  end
end
