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

        def param!(name, type, options = {})
            name = name.to_s

            return unless params.member?(name) || options[:default].present? || options[:required]

            begin
                params[name] = coerce(params[name], type, options)
                params[name] = (options[:default].call if options[:default].respond_to?(:call)) || options[:default] if params[name].nil? and options[:default]
                params[name] = options[:transform].to_proc.call(params[name]) if params[name] and options[:transform]
                validate!(params[name], options)
                if block_given?
                    controller = RailsParam::Param::MockController.new
                    controller.params = params[name]
                    yield(controller)
                end
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
                return Array(param.split(options[:delimiter] || ",")) if type == Array
                return Hash[param.split(options[:delimiter] || ",").map { |c| c.split(options[:separator] || ":") }] if type == Hash
                return (/(false|f|no|n|0)$/i === param.to_s ? false : (/(true|t|yes|y|1)$/i === param.to_s ? true : nil)) if type == TrueClass || type == FalseClass || type == :boolean
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
                end
            end
        end

    end
end
