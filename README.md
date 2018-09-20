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

## Installation

As usual, in your Gemfile...

``` ruby
  gem 'rails_param'
```

## Example

``` ruby
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

By declaring parameter types, incoming parameters will automatically be transformed into an object of that type. For instance, if a param is `:boolean`, values of `'1'`, `'true'`, `'t'`, `'yes'`, and `'y'` will be automatically transformed into `true`.  `BigDecimal` defaults to a precision of 14, but this can but changed by passing in the optional `precision:` argument. Any `$` and `,` are automatically stripped when converting to `BigDecimal`.

- `String`
- `Integer`
- `Float`
- `:boolean/TrueClass/FalseClass` _("1/0", "true/false", "t/f", "yes/no", "y/n")_
- `Array` _("1,2,3,4,5")_
- `Hash` _("key1:value1,key2:value2")_
- `Date`, `Time`, & `DateTime`
- `BigDecimal` _("$1,000,000")_

### Validations

Encapsulate business logic in a consistent way with validations. If a parameter does not satisfy a particular condition, an exception (RailsParam::Param::InvalidParameterError) is raised.
You may use the [rescue_from](http://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from) method in your controller to catch this kind of exception.

- `required`
- `blank`
- `is`
- `in`, `within`, `range`
- `min` / `max`
- `format`

Customize exception message with option `:message`

```ruby
param! :q, String, required: true, message: "Query not specified"
```

### Defaults and Transformations

Passing a `default` option will provide a default value for a parameter if none is passed.  A `default` can defined as either a default or as a `Proc`:

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

## Thank you

Many thanks to:

* [Mattt Thompson (@mattt)](https://twitter.com/mattt)
* [Vincent Ollivier (@vinc686)](https://twitter.com/vinc686)

## Contact

Nicolas Blanco

- http://github.com/nicolasblanco
- http://twitter.com/nblanco_fr
- nicolas@nicolasblanco.fr

## License

rails_param is available under the MIT license. See the LICENSE file for more info.
