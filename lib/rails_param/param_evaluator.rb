module RailsParam
  class ParamEvaluator

    CONTEXT_SEPARATOR = '.'.freeze

    attr_accessor :params

    def initialize(params, context = nil, hierarchy = nil)
      @params = params
      @context = context
      @hierarchy = hierarchy || Hash.new { |h, k| h[k] = h.dup.clear }
    end

    def param!(name, type, options = {}, &block)
      name = name.is_a?(Integer)? name : name.to_s
      return unless params.include?(name) || check_param_presence?(options[:default]) || options[:required]

      parameter_name = @context ? "#{@context}#{CONTEXT_SEPARATOR}#{name}" : name
      coerced_value = coerce(parameter_name, params[name], type, options)

      parameter = RailsParam::Parameter.new(
        name: parameter_name,
        value: coerced_value,
        type: type,
        options: options,
        &block
      )

      parameter.set_default if parameter.should_set_default?

      # validate presence
      if params[name].nil? && options[:required]
        raise InvalidParameterError.new(
          "Parameter #{parameter_name} is required",
          param: parameter_name,
          options: options
        )
      end

      path_keys = @context.split(CONTEXT_SEPARATOR) if @context
      if @context.nil? && (type == Hash || type == Array)
        # root
        @hierarchy[name] = {}
      elsif @context && (type == Hash || type == Array)
        # is an intermediate child
        @hierarchy.dig(*path_keys)[name] = type.new
      elsif @context && path_keys.present?
        # is a leaf
        leaf = @hierarchy.dig(*(path_keys[...-1]))
        leaf[path_keys.last] = [] if leaf[path_keys.last].is_a?(Hash)
        leaf[path_keys.last] << name
      end

      recurse_on_parameter(parameter, &block) if block_given?

      # apply transformation
      parameter.transform if options[:transform]

      # validate
      validate!(parameter)

      # set params value
      params[name] = parameter.value

      @hierarchy if @context.nil?
    end

    private

    def recurse_on_parameter(parameter, &block)
      return if parameter.value.nil?

      if parameter.type == Array
        parameter.value.each_with_index do |element, i|
          if element.is_a?(Hash) || element.is_a?(ActionController::Parameters)
            recurse element, "#{parameter.name}#{CONTEXT_SEPARATOR}#{i}", &block
          else
            parameter.value[i] = recurse({ i => element }, parameter.name, i, &block) # supply index as key unless value is hash
          end
        end
      else
        recurse parameter.value, parameter.name, &block
      end
    end

    def recurse(element, context, index = nil)
      raise InvalidParameterError, 'no block given' unless block_given?

      yield(ParamEvaluator.new(element, context, @hierarchy), index)
    end

    def check_param_presence? param
      !param.nil?
    end

    def coerce(param_name, param, type, options = {})
      begin
        return nil if param.nil?
        return param if (param.is_a?(type) rescue false)

        Coercion.new(param, type, options).coerce
      rescue ArgumentError, TypeError
        raise InvalidParameterError.new("'#{param}' is not a valid #{type}", param: param_name)
      end
    end

    def validate!(param)
      param.validate
    end
  end
end
