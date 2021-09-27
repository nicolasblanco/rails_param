module RailsParam
  class ParamEvaluator
    attr_accessor :params

    def initialize(params)
      @params = params
    end

    def param!(name, type, options = {}, &block)
      name = name.is_a?(Integer)? name : name.to_s
      return unless params.include?(name) || check_param_presence?(options[:default]) || options[:required]

      # coerce value
      coerced_value = coerce(
        params[name],
        type,
        options
      )
      parameter = RailsParam::Parameter.new(
        name: name,
        value: coerced_value,
        type: type,
        options: options,
        &block
      )

      parameter.set_default if parameter.should_set_default?

      # validate presence
      if params[name].nil? && options[:required]
        raise InvalidParameterError.new(
          "Parameter #{name} is required",
          param: name,
          options: options
        )
      end

      recurse_on_parameter(parameter, &block) if block_given?

      # apply transformation
      parameter.transform if params.include?(name) && options[:transform]

      # validate
      validate!(parameter)

      # set params value
      params[name] = parameter.value
    end

    private

    def recurse_on_parameter(parameter, &block)
      if parameter.type == Array
        unless parameter.value.respond_to?(:each_with_index)
          raise(
            InvalidParameterError,
            "'#{parameter.value}' is not a valid #{parameter.type}"
          )
        end

        parameter.value.each_with_index do |element, i|
          if element.is_a?(Hash) || element.is_a?(ActionController::Parameters)
            recurse element, &block
          else
            parameter.value[i] = recurse({ i => element }, i, &block) # supply index as key unless value is hash
          end
        end
      else
        recurse parameter.value, &block
      end
    end

    def recurse(element, index = nil)
      raise InvalidParameterError, 'no block given' unless block_given?

      yield(ParamEvaluator.new(element), index)
    end

    def check_param_presence? param
      !param.nil?
    end

    def coerce(param, type, options = {})
      begin
        return param if (param.is_a?(type) rescue false)

        Coercion.new(param, type, options).coerce
      rescue ArgumentError, TypeError
        raise InvalidParameterError, "'#{param}' is not a valid #{type}"
      end
    end

    def validate!(param)
      param.validate
    end
  end
end
