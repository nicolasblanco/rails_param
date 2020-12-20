module RailsParam
  module Param
    class Coercion
      class TimeParam
        attr_reader :param, :options, :type

        TIME_TYPES = [Date, DateTime, Time].freeze

        def initialize(param:, options: nil, type: nil)
          @param = param
          @options = options
          @type = type
        end

        def coerce
          return type.strptime(param, options[:format]) if options[:format].present?

          type.parse(param)
        end
      end
    end
  end
end
