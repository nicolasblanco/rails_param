module RailsParam
  module Param
    class Coercion
      class ArrayParam < VirtualParam
        def coerce
          raise ArgumentError unless param.respond_to?(:split)

          Array(param.split(options[:delimiter] || ","))
        end

        private

        def argument_validation
          raise ArgumentError if param.is_a?(Array) && type != Array
        end
      end
    end
  end
end
