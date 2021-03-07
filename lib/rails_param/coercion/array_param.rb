module RailsParam
  module Param
    class Coercion
      class ArrayParam < VirtualParam
        def coerce
          return param if param.is_a?(Array)

          Array(param.split(options[:delimiter] || ","))
        end

        private

        def argument_validation
          raise ArgumentError if type != Array
          raise ArgumentError unless param.respond_to?(:split)
        end
      end
    end
  end
end
