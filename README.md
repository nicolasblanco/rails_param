# rails-param
_Parameter Validation & Type Coercion for Rails_

[![Build Status](https://travis-ci.org/nicolasblanco/rails_param.svg?branch=master)](https://travis-ci.org/nicolasblanco/rails_param)

This is a port of the gem [sinatra-param](https://github.com/mattt/sinatra-param) for the Rails framework.
All the credits go to [@mattt](https://twitter.com/mattt).
It has all the features of the sinatra-param gem, I used bang methods (like param!) to indicate that they are destructive as they change the controller params object and may raise an exception.

REST conventions take the guesswork out of designing and consuming web APIs. Simply `GET`, `POST`, `PATCH`, or `DELETE` resource endpoints, and you get what you'd expect.

However, when it comes to figuring out what parameters are expected... well, all bets are off.

This Rails extension takes a first step to solving this problem on the developer side.

**`rails-param` allows you to declare, validate, and transform endpoint parameters as you would in frameworks like [ActiveModel](http://rubydoc.info/gems/activemodel/3.2.3/frames) or [DataMapper](http://datamapper.org/).**

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
    param! :price,       String, format: "[<\=>]\s*\$\d+"

    # Access the parameters using the params object (like params[:q]) as you usually do...
  end
end
```

### Parameter Types

By declaring parameter types, incoming parameters will automatically be transformed into an object of that type. For instance, if a param is `Boolean`, values of `'1'`, `'true'`, `'t'`, `'yes'`, and `'y'` will be automatically transformed into `true`.

- `String`
- `Integer`
- `Float`
- `:boolean/TrueClass/FalseClass` _("1/0", "true/false", "t/f", "yes/no", "y/n")_
- `Array` _("1,2,3,4,5")_
- `Hash` _("key1:value1,key2:value2")_
- `Date`, `Time`, & `DateTime`

### Validations

Encapsulate business logic in a consistent way with validations. If a parameter does not satisfy a particular condition, an exception (RailsParam::Param::InvalidParameterError) is raised.
You may use the [rescue_from](http://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from) method in your controller to catch this kind of exception.

- `required`
- `blank`
- `is`
- `in`, `within`, `range`
- `min` / `max`
- `format`

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

rails-param is available under the MIT license. See the LICENSE file for more info.
