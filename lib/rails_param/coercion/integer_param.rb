module RailsParam
  module Param
    class Coercion
      class IntegerParam
        attr_reader :param, :options, :type

        def initialize(param:, options: nil, type: nil)
          @param, @options, @type = param, options, type
        end

        def coerce
          Integer(param)
        end
      end
    end
  end
end
