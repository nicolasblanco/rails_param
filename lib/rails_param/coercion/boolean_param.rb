module RailsParam
  module Param
    class Coercion
      class BooleanParam
        attr_reader :param, :options, :type

        FALSEY = /^(false|f|no|n|0)$/i.freeze
        TRUTHY = /^(true|t|yes|y|1)$/i.freeze

        def initialize(param:, options: nil, type: nil)
          @param = param
          @options = options
          @type = type
        end

        def coerce
          return false if FALSEY === param.to_s
          return true if TRUTHY === param.to_s

          raise ArgumentError
        end
      end
    end
  end
end
