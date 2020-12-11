require 'pry'
module RailsParam
  module Param

    TIME_TYPES = [Date, DateTime, Time].freeze
    STRING_OR_TIME_TYPES = ([String] + TIME_TYPES).freeze

    class MockController
      include RailsParam::Param
      attr_accessor :params
    end

    def param!(name, type, options = {}, &block)
      name = name.to_s unless name.is_a? Integer # keep index for validating elements

      return unless params.include?(name) || check_param_presence?(options[:default]) || options[:required]

      begin
        parameter = RailsParam::Param::Parameter.new(
          value: coerce(params[name], type, options),
          options: options
        )

        parameter.set_default if parameter.should_set_default?

        # apply transformation
        if params.include?(name) && options[:transform]
          parameter.transform
        end

        # validate
        validate!(parameter.value, name, options)

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

        params[name] = parameter.value

      rescue InvalidParameterError => exception
        exception.param ||= name
        exception.options ||= options
        raise exception
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
        return param if (param.is_a?(ActionController::Parameters) && type == Hash rescue false)

        Coercion.new(param, type, options).coerce
      rescue ArgumentError, TypeError
        raise InvalidParameterError, "'#{param}' is not a valid #{type}"
      end
    end

    def validate!(param, param_name, options)
      options.each do |key, value|
        case key
          when :required
            raise InvalidParameterError, "Parameter #{param_name} is required" if value && param.nil?
          when :blank
            raise InvalidParameterError, "Parameter #{param_name} cannot be blank" if !value && case param
                                                                                    when String
                                                                                      !(/\S/ === param)
                                                                                    when Array, Hash, ActionController::Parameters
                                                                                      param.empty?
                                                                                    else
                                                                                      param.nil?
                                                                                  end
          when :format
            raise InvalidParameterError, "Parameter #{param_name} must be a string if using the format validation" unless STRING_OR_TIME_TYPES.any? { |cls| param.kind_of? cls }
            raise InvalidParameterError, "Parameter #{param_name} must match format #{value}" if param.kind_of?(String) && param !~ value
          when :is
            raise InvalidParameterError, "Parameter #{param_name} must be #{value}" unless param === value
          when :in, :within, :range
            raise InvalidParameterError, "Parameter #{param_name} must be within #{value}" unless param.nil? || case value
                                                                                                    when Range
                                                                                                      value.include?(param)
                                                                                                    else
                                                                                                      Array(value).include?(param)
                                                                                                  end
          when :min
            raise InvalidParameterError, "Parameter #{param_name} cannot be less than #{value}" unless param.nil? || value <= param
          when :max
            raise InvalidParameterError, "Parameter #{param_name} cannot be greater than #{value}" unless param.nil? || value >= param
          when :min_length
            raise InvalidParameterError, "Parameter #{param_name} cannot have length less than #{value}" unless param.nil? || value <= param.length
          when :max_length
            raise InvalidParameterError, "Parameter #{param_name} cannot have length greater than #{value}" unless param.nil? || value >= param.length
          when :custom
            value.call(param)
        end
      end
    end

  end
end
