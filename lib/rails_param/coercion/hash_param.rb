module RailsParam
  module Param
    class Coercion
      class HashParam < VirtualParam
        def coerce
          raise ArgumentError unless param.respond_to?(:split)

          Hash[param.split(options[:delimiter] || ",").map { |c| c.split(options[:separator] || ":") }]
        end

        private

        def argument_validation
          raise ArgumentError if param.is_a?(Hash) || param.is_a?(ActionController::Parameters) && type != Hash
        end
      end
    end
  end
end
