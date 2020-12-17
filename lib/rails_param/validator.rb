module RailsParam
  module Param
    class Validator
      attr_reader :parameter

      def initialize(parameter)
        @parameter = parameter
      end

      def validate!
        parameter.options.each_key do |key|
          klass = camelize(key)
          Validator.const_get(klass).new(parameter).valid!
        end
      end

      def valid!
        raise InvalidParameterError, error_message unless valid_value?
      end

      private
      # Converts a symbol to a class name, taken from rails
      def camelize(term)
        string = term.to_s
        string = string.sub(/^[a-z\d]*/) { Regexp.last_match(0).capitalize }
        string.gsub(%r{ /(?:_|(/))([a-z\d]*)/i }) { Regexp.last_match(2).capitalize }.gsub('/', '::')
      end

      def error_message
        "Error message must be defined on Validator subclass"
      end

      def valid_value?
        # Should be overwritten in subclass
        false
      end
    end
  end
end
