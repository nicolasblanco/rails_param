module RailsParam
  module Param
    class Coercion
      class HashParam
        attr_reader :param, :options, :type

        def initialize(param:, options: nil, type: nil)
          @param, @options, @type = param, options, type
        end

        def coerce
          raise ArgumentError unless param.respond_to?(:split)

          Hash[param.split(options[:delimiter] || ",").map { |c| c.split(options[:separator] || ":") }]
        end
      end
    end
  end
end
