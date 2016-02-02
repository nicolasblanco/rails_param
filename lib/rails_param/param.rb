module RailsParam
  module Param

    DEFAULT_PRECISION = 14

    class InvalidParameterError < StandardError
      attr_accessor :param, :options, :full_path_array

      def initialize(msg)
        super(msg)
        @full_path_array = []
      end

      def full_path
        str = ""
        full_path_array.each_with_index do |a, index|
          str += (index == 0) ? a : "[#{a}]"
        end
        str
      end
    end

    class MockController
      include RailsParam::Param
      attr_accessor :params
    end

    def param!(name, type, options = {}, &block)
      evaluating_index = nil # used to keep track of array indexes

      # keep index for validating elements if integer
      name = name.to_s unless name.is_a? Integer

      unless(params.member?(name) ||
            check_param_presence?(options[:default]) ||
            options[:required])
        return
      end

      begin
        # coerce
        params[name] = coerce(params[name], type, options)

        # set default
        if options[:default].respond_to?(:call)
          params[name] = options[:default].call
        elsif params[name].nil? && check_param_presence?(options[:default])
          params[name] = options[:default]
        end

        # apply tranformation
        if params[name] && options[:transform]
          params[name] = options[:transform].to_proc.call(params[name])
        end

        # validate
        validate!(params[name], options)

        # handle nested params
        if block_given?
          if type == Array
            params[name].each_with_index do |element, i|
              if element.is_a?(Hash)
                evaluating_index = i
                recurse element, &block
              else
                # supply index as key unless value is hash
                params[name][i] = recurse({ i => element }, i, &block)
              end
            end
          else
            recurse params[name], &block
          end
        end
        params[name]

      rescue InvalidParameterError => exception
        unless evaluating_index.nil?
          exception.full_path_array.unshift(evaluating_index)
        end
        exception.full_path_array.unshift(name)
        exception.param ||= name
        exception.options ||= options
        raise exception
      end
    end

    private

    def check_param_presence? param
      !param.nil?
    end

    def recurse(params, index = nil)
      raise InvalidParameterError, 'no block given' unless block_given?
      controller = RailsParam::Param::MockController.new
      controller.params = params
      yield(controller, index)
    end

    def coerce(param, type, options = {})
      begin
        return nil if param.nil?
        return param if (param.is_a?(type) rescue false)
        return Integer(param) if type == Integer
        return Float(param) if type == Float
        return String(param) if type == String
        return Date.parse(param) if type == Date
        return Time.parse(param) if type == Time
        return DateTime.parse(param) if type == DateTime

        if type == Array
          raise ArgumentError unless param.respond_to?(:split)
          return Array(param.split(options[:delimiter] || ","))
        end

        if type == Hash
          raise ArgumentError unless param.respond_to?(:split)
          delimiter = options[:delimiter] || ","
          seperator = options[:separator] || ":"
          return Hash[param.split(delimiter).map {|c| c.split(seperator)}]
        end

        if type == TrueClass || type == FalseClass || type == :boolean
          return (/^(false|f|no|n|0)$/i === param.to_s ? false : (/^(true|t|yes|y|1)$/i === param.to_s ? true : (raise ArgumentError)))
        end

        if type == BigDecimal
          param = param.delete('$,').strip.to_f if param.is_a?(String)
          return BigDecimal.new(param, (options[:precision] || DEFAULT_PRECISION))
        end
        return nil
      rescue ArgumentError
        raise InvalidParameterError, "'#{param}' is not a valid #{type}"
      end
    end

    def validate!(param, options)
      options.each do |key, value|
        case key
          when :required
            raise InvalidParameterError, "Parameter is required" if value && param.nil?
          when :blank
            raise InvalidParameterError, "Parameter cannot be blank" if !value && case param
                                                                                    when String
                                                                                      !(/\S/ === param)
                                                                                    when Array, Hash
                                                                                      param.empty?
                                                                                    else
                                                                                      param.nil?
                                                                                  end
          when :format
            raise InvalidParameterError, "Parameter must be a string if using the format validation" unless param.kind_of?(String)
            raise InvalidParameterError, "Parameter must match format #{value}" unless param =~ value
          when :is
            raise InvalidParameterError, "Parameter must be #{value}" unless param === value
          when :in, :within, :range
            raise InvalidParameterError, "Parameter must be within #{value}" unless param.nil? || case value
                                                                                                    when Range
                                                                                                      value.include?(param)
                                                                                                    else
                                                                                                      Array(value).include?(param)
                                                                                                  end
          when :min
            raise InvalidParameterError, "Parameter cannot be less than #{value}" unless param.nil? || value <= param
          when :max
            raise InvalidParameterError, "Parameter cannot be greater than #{value}" unless param.nil? || value >= param
          when :min_length
            raise InvalidParameterError, "Parameter cannot have length less than #{value}" unless param.nil? || value <= param.length
          when :max_length
            raise InvalidParameterError, "Parameter cannot have length greater than #{value}" unless param.nil? || value >= param.length
          when :custom
            value.validate!(param)
        end
      end
    end

  end
end
