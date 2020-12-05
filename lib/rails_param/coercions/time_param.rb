module RailsParam
  class TimeParam
    attr_reader :param, :options, :type

    TIME_TYPES = [Date, DateTime, Time].freeze


    def initialize(param:, options: nil, type: nil)
      @param, @options, @type = param, options, type
    end

    def coerce
      if TIME_TYPES.include? type
        if options[:format].present?
          return type.strptime(param, options[:format])
        else
          return type.parse(param)
        end
      end
    end
  end
end
