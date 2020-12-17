module RailsParam
  module Param
    class Coercion
      class BooleanParam
        attr_reader :param, :options, :type

        def initialize(param:, options: nil, type: nil)
          @param, @options, @type = param, options, type
        end

        def coerce
          return false if /^(false|f|no|n|0)$/i === param.to_s
          return true if /^(true|t|yes|y|1)$/i === param.to_s

          raise ArgumentError
        end
      end
    end
  end
end
