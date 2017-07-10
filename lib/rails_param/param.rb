module RailsParam
  module Param

    DEFAULT_PRECISION = 14

    class InvalidParameterError < StandardError
      attr_accessor :param, :options
    end

    class MockController
      include RailsParam::Param
      attr_accessor :params
    end

    def param!(name, type, options = {}, &block)
      name = name.to_s unless name.is_a? Integer # keep index for validating elements

      return unless params.include?(name) || check_param_presence?(options[:default]) || options[:required]

      begin
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
        validate!(params[name], name, options)

        if block_given?
          if type == Array
            params[name].each_with_index do |element, i|
              if element.is_a?(Hash) || element.is_a?(ActionController::Parameters)
                recurse element, &block
              else
                params[name][i] = recurse({ i => element }, i, &block) # supply index as key unless value is hash
              end
            end
          else
            recurse params[name], &block
          end
        end
        params[name]

      rescue InvalidParameterError => exception
        exception.param ||= name
        exception.options ||= options
        raise exception
      end
    end

    # TODO: should we reintegrate this method?
    # def one_of!(*names)
    #   count = 0
    #   names.each do |name|
    #     if params[name] and params[name].present?
    #       count += 1
    #       next unless count > 1
    #
    #       error = "Parameters #{names.join(', ')} are mutually exclusive"
    #       if content_type and content_type.match(mime_type(:json))
    #         error = {message: error}.to_json
    #       end
    #
    #       # do something with error object
    #     end
    #   end
    # end

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
        return Integer(param) if type == Integer
        return Float(param) if type == Float
        return String(param) if type == String
        return Date.parse(param) if type == Date
        return Time.parse(param) if type == Time
        return DateTime.parse(param) if type == DateTime
        return Array(param.split(options[:delimiter] || ",")) if type == Array
        return Hash[param.split(options[:delimiter] || ",").map { |c| c.split(options[:separator] || ":") }] if type == Hash
        return (/^(false|f|no|n|0)$/i === param.to_s ? false : (/^(true|t|yes|y|1)$/i === param.to_s ? true : (raise ArgumentError))) if type == TrueClass || type == FalseClass || type == :boolean
        if type == BigDecimal
          param = param.delete('$,').strip.to_f if param.is_a?(String)
          return BigDecimal.new(param, (options[:precision] || DEFAULT_PRECISION))
        end
        return nil
      rescue ArgumentError
        raise InvalidParameterError, I18n.t(
              'invalid',
              param: param,
              type: type,
              default: "'#{param}' is not a valid #{type}",
              scope: [:rails_param, :type]
            )
      end
    end

    def validate!(param, param_name, options)
      options.each do |key, value|
        case key
          when :required
            raise InvalidParameterError, I18n.t(
              'required_missing',
              param_name: param_name,
              default: "Parameter #{param_name} is required",
              scope: [:rails_param, :empty]
            ) if value && param.nil?
          when :blank
            raise InvalidParameterError, I18n.t(
              'empty',
              param_name: param_name,
              default: "Parameter #{param_name} cannot be blank",
              scope: [:rails_param, :empty]
            ) if !value && case param
                             when String
                               !(/\S/ === param)
                             when Array, Hash
                               param.empty?
                             else
                               param.nil?
                           end
          when :format
            raise InvalidParameterError, I18n.t(
              'format_not_string',
              param_name: param_name,
              default: "Parameter #{param_name} must be a string if using the format validation",
              scope: [:rails_param, :format]
            ) unless param.kind_of?(String)
            raise InvalidParameterError, I18n.t(
              'format_not_matching',
              param_name: param_name,
              value: value,
              default: "Parameter #{param_name} must match format #{value}",
              scope: [:rails_param, :format]
            ) unless param =~ value
          when :is
            raise InvalidParameterError, I18n.t(
              'format_not_values',
              param_name: param_name,
              value: value,
              default: "Parameter #{param_name} must be #{value}",
              scope: [:rails_param, :format]
            ) unless param === value
          when :in, :within, :range
            raise InvalidParameterError, I18n.t(
              'not_in_range',
              param_name: param_name,
              value: value,
              default: "Parameter #{param_name} must be within #{value}",
              scope: [:rails_param, :value]
            ) unless param.nil? || case value
                                          when Range
                                            value.include?(param)
                                          else
                                            Array(value).include?(param)
                                        end
          when :min
            raise InvalidParameterError, I18n.t(
              'not_less_than',
              param_name: param_name,
              value: value,
              default: "Parameter #{param_name} cannot be less than #{value}",
              scope: [:rails_param, :value]
            ) unless param.nil? || value <= param
          when :max
            raise InvalidParameterError, I18n.t(
              'not_greater_than',
              param_name: param_name,
              value: value,
              default: "Parameter #{param_name} cannot be greater than #{value}",
              scope: [:rails_param, :value]
            ) unless param.nil? || value >= param
          when :min_length
            raise InvalidParameterError, I18n.t(
              'too_short',
              param_name: param_name,
              value: value,
              default: "Parameter #{param_name} cannot have length less than #{value}",
              scope: [:rails_param, :length]
            ) unless param.nil? || value <= param.length
          when :max_length
            raise InvalidParameterError, I18n.t(
              'too_big',
              param_name: param_name,
              value: value,
              default: "Parameter #{param_name} cannot have length greater than #{value}",
              scope: [:rails_param, :length]
            ) unless param.nil? || value >= param.length
        end
      end
    end
  end
end
