module RailsParam
  class ParamEvaluator
    attr_accessor :params

    def initialize(params, context = nil, hierarchy = nil)
      @params = params
      @context = context
      @hierarchy = hierarchy || {}
    end

    def param!(name, type, options = {}, &block)
      @child_key = name = name.is_a?(Integer)? name : name.to_s
      return unless params.include?(name) || check_param_presence?(options[:default]) || options[:required]

      parameter_name = @context ? "#{@context}[#{name}]" : name
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

      update_hierarchy(type, name)

      recurse_result = recurse_on_parameter(parameter, &block) if block_given?
      @hierarchy[@child_key] = recurse_result

      # apply transformation
      parameter.transform if options[:transform]

      # validate
      validate!(parameter)

      # set params value
      params[name] = parameter.value

      [@hierarchy, parameter.value]
    end

    private

    def update_hierarchy(type, name)
      # calculate next child type
      @child =
        if type == Array && !block_given?
          []
        elsif type == Hash || type == Array
          {}
        else
          name
        end

      if type == Hash || type == Array
        # intermediate nodes
        if @hierarchy.is_a?(Hash)
          @hierarchy[name] = @child
          @child_key = name
        else
          @hierarchy << @child
          @child_key = @hierarchy.size - 1
        end
      else
        # this is a leaf
        @hierarchy = [] if @hierarchy.is_a?(Hash)
        @hierarchy << name
        @child_key = @hierarchy.size - 1
      end
    end

    def recurse_on_parameter(parameter, &block)
      return if parameter.value.nil?

      if parameter.type == Array
        parameter.value.each_with_index do |element, i|
          if element.is_a?(Hash) || element.is_a?(ActionController::Parameters)
            recurse element, "#{parameter.name}[#{i}]", &block
          else
            _, value = recurse({ i => element }, parameter.name, i, &block) # supply index as key unless value is hash
            parameter.value[i] = value
          end
        end
      else
        recurse parameter.value, parameter.name, &block
      end
    end

    def recurse(element, context, index = nil)
      raise InvalidParameterError, 'no block given' unless block_given?

      yield(ParamEvaluator.new(element, context, @hierarchy[@child_key]), index)
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
