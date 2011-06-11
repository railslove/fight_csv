# Constructable [![Build Status](http://travis-ci.org/mkorfmann/constructable.png)](http://travis-ci.org/mkorfmann/constructable)

Provides a powerful class macro for defining and configuring constructable attributes of a class.

## Facts

* Doesn't break default initialize behaviour(see test/constructable/test_constructable 'should not break the initialize behaviour')
* Only does what you expect it to do (no real magic involved)
* Validates your attributes
* Provides a granular control on how accessible your attributes are(no need to define attr_* yourself)

## Usage
```ruby
class Foo
  constructable [:bar, :readable => true], [:baz, :required => true, :readable => true]
end

foo = Foo.new(bar: 5)
# raises AttributeError, ':baz is a required attribute'

foo = Foo.new(baz: 7, bar: 5)

foo.bar
# => 5
foo.baz
# => 7

class ProgrammingLanguage
  constructable [:paradigms,
    readable: true,
    required: true,
    validate_type: Array]
end

c = ProgrammingLanguage.new(paradigms: :functional)
#  raises AttributeError, ':paradigms needs to be of type Array'

ruby = ProgrammingLanguage.new(paradigms: [:object_oriented, :functional])
ruby.paradigms
# => [:object_oriented, :functional]
```


## Contributing to constructable
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright
Copyright (c) 2011 Manuel Korfmann. See LICENSE.txt for
further details.

