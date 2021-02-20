module RailsParam
  module Param
    class Coercion
      class IntegerParam < VirtualParam
        def coerce
          Integer(param)
        end
      end
    end
  end
end
