module RailsParam
  module Param
    class Coercion
      class HashParam < VirtualParam
        def coerce
          return param if param.is_a?(ActionController::Parameters)
          raise ArgumentError unless param.respond_to?(:split)

          Hash[param.split(options[:delimiter] || ",").map { |c| c.split(options[:separator] || ":") }]
        end

        private

        def argument_validation
          raise ArgumentError unless type == Hash
        end
      end
    end
  end
end
