module RailsParam
  module Param
    class Coercion
      class TimeParam < VirtualParam
        TIME_TYPES = [Date, DateTime, Time].freeze

        def coerce
          return type.strptime(param, options[:format]) if options[:format].present?

          type.parse(param)
        end
      end
    end
  end
end
