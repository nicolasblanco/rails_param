module RailsParam
  module Param
    class Coercion
      class HashParam < VirtualParam
        def coerce
          Hash[param.split(options[:delimiter] || ",").map { |c| c.split(options[:separator] || ":") }]
        end

        private

        def argument_validation
          raise ArgumentError unless type == Hash
          raise ArgumentError unless param.respond_to?(:split)
        end
      end
    end
  end
end
