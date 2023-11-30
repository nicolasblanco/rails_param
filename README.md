# rails_param

_Parameter Validation & Type Coercion for Rails_

[![Gem Version](https://badge.fury.io/rb/rails_param.svg)](https://rubygems.org/gems/rails_param)
[![Build Status](https://travis-ci.org/nicolasblanco/rails_param.svg?branch=master)](https://travis-ci.org/nicolasblanco/rails_param)

## Introduction

This library is handy if you want to validate a few numbers of parameters directly inside your controller.

For example : you are building a search action and want to validate that the `sort` parameter is set and only set to something like `desc` or `asc`.

## Important

This library should not be used to validate a large number of parameters or parameters sent via a form or namespaced (like `params[:user][:first_name]`). There is already a great framework included in Rails (ActiveModel::Model) which can be used to create virtual classes with all the validations you already know and love from Rails. Remember to always try to stay in the “thin controller” rule.

See [this](http://blog.remarkablelabs.com/2012/12/activemodel-model-rails-4-countdown-to-2013) page to see an example on how to build a contact form using ActiveModel::Model.

But sometimes, it’s not practical to create an external class just to validate and convert a few parameters. In this case, you may use this gem. It allows you to easily do validations and conversion of the parameters directly in your controller actions using a simple method call.

## Credits

This is originally a port of the gem [sinatra-param](https://github.com/mattt/sinatra-param) for the Rails framework.

All the credits go to [@mattt](https://twitter.com/mattt).

It has all the features of the sinatra-param gem, I used bang methods (like param!) to indicate that they are destructive as they change the controller params object and may raise an exception.

## Upgrading

Find a list of breaking changes in [UPGRADING](UPGRADING.md).

## Installation

As usual, in your Gemfile...

```ruby
  gem 'rails_param'
```

## Example

```ruby
  # GET /search?q=example
  # GET /search?q=example&categories=news
  # GET /search?q=example&sort=created_at&order=ASC
  def search
    param! :q,           String, required: true
    param! :categories,  Array
    param! :sort,        String, default: "title"
    param! :order,       String, in: %w(asc desc), transform: :downcase, default: "asc"
    param! :price,       String, format: /[<\=>]\s*\$\d+/

    # Access the parameters using the params object (like params[:q]) as you usually do...
  end
end
```

### Parameter Types

By declaring parameter types, incoming parameters will automatically be transformed into an object of that type. For instance, if a param is `:boolean`, values of `'1'`, `'true'`, `'t'`, `'yes'`, and `'y'` will be automatically transformed into `true`. `BigDecimal` defaults to a precision of 14, but this can but changed by passing in the optional `precision:` argument. Any `$` and `,` are automatically stripped when converting to `BigDecimal`.

- `String`
- `Integer`
- `Float`
- `:boolean/TrueClass/FalseClass` _("1/0", "true/false", "t/f", "yes/no", "y/n")_
- `Array` _("1,2,3,4,5")_
- `Hash` _("key1:value1,key2:value2")_
- `Date`, `Time`, & `DateTime`
- `BigDecimal` _("$1,000,000")_

### Validations

Encapsulate business logic in a consistent way with validations. If a parameter does not satisfy a particular condition, an exception (RailsParam::InvalidParameterError) is raised.
You may use the [rescue_from](http://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from) method in your controller to catch this kind of exception.

- `required`
- `blank`
- `is`
- `in`, `within`, `range`
- `min` / `max`
- `min_length` / `max_length`
- `format`

Customize exception message with option `:message`

```ruby
param! :q, String, required: true, message: "Query not specified"
```

### Defaults and Transformations

Passing a `default` option will provide a default value for a parameter if none is passed. A `default` can defined as either a default or as a `Proc`:

```ruby
param! :attribution, String, default: "©"
param! :year, Integer, default: lambda { Time.now.year }
```

Use the `transform` option to take even more of the business logic of parameter I/O out of your code. Anything that responds to `to_proc` (including `Proc` and symbols) will do.

```ruby
param! :order, String, in: ["ASC", "DESC"], transform: :upcase, default: "ASC"
param! :offset, Integer, min: 0, transform: lambda {|n| n - (n % 10)}
```

### Nested Attributes

rails_param allows you to apply any of the above mentioned validations to attributes nested in hashes:

```ruby
param! :book, Hash do |b|
  b.param! :title, String, blank: false
  b.param! :price, BigDecimal, precision: 4, required: true
  b.param! :author, Hash, required: true do |a|
    a.param! :first_name, String
    a.param! :last_name, String, blank: false
  end
end
```

### Arrays

Validate every element of your array, including nested hashes and arrays:

```ruby
# primitive datatype syntax
param! :integer_array, Array do |array,index|
  array.param! index, Integer, required: true
end

# complex array
param! :books_array, Array, required: true  do |b|
  b.param! :title, String, blank: false
  b.param! :author, Hash, required: true do |a|
    a.param! :first_name, String
    a.param! :last_name, String, required: true
  end
  b.param! :subjects, Array do |s,i|
    s.param! i, String, blank: false
  end
end
```

## Internationalization (i18n) Support 🌍

RailsParam gem supports internationalization (i18n) for its error messages. This allows you to translate the error messages into different languages or customize them as per your requirements.

The gem comes with a default set of error messages in English ('en') to get you started. You can find the locale file in the `lib/i18n/locales` directory of this GitHub repository. 📁

You don't need to create the 'en' locale file if you don't want to override the default error messages.

However, you can add your own translations for other languages by following these steps:

- Ensure that you have the i18n gem installed in your Rails application. If not, add it to your Gemfile and run `bundle install`. 💎

- Create or update the translation file for the desired locale. 🌐

```yaml
fr:
  rails_param:
    errors:
      invalid_type: "'%{value}' n'est pas un %{type} valide"
      required: "Le paramètre %{name} est requis"
      no_block: "aucun bloc donné"
      blank: "Le paramètre %{name} ne peut pas être vide"
      invalid_string_or_time: "Le paramètre %{name} doit être une chaîne de caractères s'il utilise la validation du format"
      invalid_string_format: "Le paramètre %{name} doit correspondre au format %{format_pattern}"
      in: "Le paramètre %{name} doit être compris entre %{in}"
      is: "Le paramètre %{name} doit être %{is}"
      max_length: "Le paramètre %{name} ne peut pas avoir une longueur supérieure à %{max_length}"
      max: "Le paramètre %{name} ne peut pas être supérieur à %{max}"
      min_length: "Le paramètre %{name} ne peut pas avoir une longueur inférieure à %{min_length}"
      min: "Le paramètre %{name} ne peut pas être inférieur à %{min}"
```

- When an error occurs, RailsParam will automatically look up the translation key based on the current locale and provide the translated error message. 🔄

### Variables in the Locale YAML File 📝

The locale YAML file for RailsParam gem provides the following variables that can be used to create dynamic error messages:

- **`name`**: Represents the name of the parameter being validated. This variable allows you to include the parameter's name dynamically in the error message. For example, if the parameter name is "username," you can use `%{name}` in the error message to reference the parameter name.

- **`value`**: Represents the value of the parameter that was passed by the user. This variable allows you to include the actual value in the error message. For example, if the user passed the value "john.doe" for the parameter, you can use `%{value}` in the error message to reference the actual value.

- **`type`:** Represents the expected type of the parameter in the validation. This variable allows you to include the expected type dynamically in the error message. For example, if the expected type is "string," you can use `%{type}` in the error message to reference the expected type.

- **`format_pattern`**: Represents the expected format pattern in format validation. This variable allows you to include the expected format pattern dynamically in the error message. For example, if the expected format pattern is "YYYY-MM-DD," you can use `%{format_pattern}` in the error message to reference the expected format pattern.

- **`in`**: Represents the expected set of values in the 'in' validation. This variable allows you to include the expected set of values dynamically in the error message. For example, if the expected set of values is ["red", "green", "blue"], you can use `%{in}` in the error message to reference the expected set of values.

- **`is`**: Represents a specific value that the parameter should be equal to in the validation. This variable allows you to include the expected value dynamically in the error message. For example, if the parameter should be equal to 10, you can use `%{is}` in the error message to reference the expected value.

- **`max_length`**: Represents the maximum length allowed for the parameter. This variable allows you to include the maximum length dynamically in the error message. For example, if the maximum length is 50, you can use `%{max_length}` in the error message to reference the maximum length.

- **`max`**: Represents the maximum value allowed for the parameter. This variable allows you to include the maximum value dynamically in the error message. For example, if the maximum value is 100, you can use `%{max}` in the error message to reference the maximum value.

- **`min_length`**: Represents the minimum length required for the parameter. This variable allows you to include the minimum length dynamically in the error message. For example, if the minimum length is 5, you can use `%{min_length}` in the error message to reference the minimum length.

- **`min`**: Represents the minimum value required for the parameter. This variable allows you to include the minimum value dynamically in the error message. For example, if the minimum value is 0, you can use `%{min}` in the error message to reference the minimum value.

If you want to contribute translations for additional languages or customize the existing translations, please refer to the i18n gem documentation for more details on how to manage translation files.

## Thank you

Many thanks to:

- [Mattt Thompson (@mattt)](https://twitter.com/mattt)
- [Vincent Ollivier (@vinc686)](https://twitter.com/vinc686)

## Contact

Nicolas Blanco

- http://github.com/nicolasblanco
- http://twitter.com/nblanco_fr
- nicolas@nicolasblanco.fr

## License

rails_param is available under the MIT license. See the LICENSE file for more info.
