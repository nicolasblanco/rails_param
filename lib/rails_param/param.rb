module RailsParam
  module Param
    class MockController
      include RailsParam::Param
      attr_accessor :params
    end

    def param!(name, type, options = {}, &block)
      name = name.to_s unless name.is_a? Integer # keep index for validating elements

      return unless params.include?(name) || check_param_presence?(options[:default]) || options[:required]

      begin

        # coerce value
        coerced_value = coerce(
          params[name],
          type,
          options
        )
        parameter = RailsParam::Param::Parameter.new(
          name: name,
          value: coerced_value,
          type: type,
          options: options
        )

        # set default
        parameter.set_default if parameter.should_set_default?

        # validate presence
        if params[name].nil? && options[:required]
          raise InvalidParameterError.new(
            "Parameter #{name} is required",
            param: name,
            options: options
          )
        end

        # apply transformation
        parameter.transform if params.include?(name) && options[:transform]

        # validate
        validate!(parameter)

        if block_given?
          if type == Array
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

        # set params value
        params[name] = parameter.value
      end
    end

    private

    def check_param_presence? param
      not param.nil?
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
