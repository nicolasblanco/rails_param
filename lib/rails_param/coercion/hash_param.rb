module RailsParam
  class Coercion
    class HashParam < VirtualParam
      def coerce
        delimiter = options[:delimiter] || ","
        separator = options[:separator] || ":"

        return param if param.is_a?(ActionController::Parameters)
        raise ArgumentError unless param.respond_to?(:split)
        raise ArgumentError unless param.include?(separator)

        Hash[param.split(delimiter).map { |c| c.split(separator) }]
      end

      private

      def argument_validation
        raise ArgumentError unless type == Hash
      end
    end
  end
end
