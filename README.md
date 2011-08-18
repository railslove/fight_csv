# Fight CSV!

It's 2011, and parsing CSV with Ruby still sucks? Enter FightCSV! It
will take the cumbersome out of your CSV parsing, while keeping the
awesome! Want some taste of that juicy fresh? Check out this example:

Consider you have a csv file called log_entries.csv which looks like
this:

```
Date,Person,Client/Project,Minutes,Tags,Billable
2011-08-15,John Doe,handsomelabs,60,blogpost,no
2011-08-15,Max Powers,beerbrewing,60,meeting,yes
2011-08-15,Tyler Durden,babysitting,180,"concepting, research",yes
2011-08-15,Hulk Hero,gardening,60,"meeting, research",no
2011-08-15,John Doe,handsomelabs,60,coding,yes
2011-08-08,John Doe,handsomelabs,60,"blabla, meeting",yes
```

## Schema

Now you can define a class representing a row of the file. You only need
to include ```FightCSV::Record```.

```ruby
class LogEntry
  include FightCSV::Record
end
```

But of course you want the values from each row to behave like proper
Ruby objects. This can be easily achieved by defining a schema in the
```LogEntry``` class:

```ruby
class LogEntry
  include FightCSV::Record
  schema do
    field "Name"
    field "Client/Project", {
      identifier: :project
    }
  end
end
```

Now the LogEntry objects will have a ```name``` method corresponding to
the column called "Name" and a ```project``` method corresponding to the
column called "Client/Project".

But sometimes you don't only want to adjust the field names, but also
the values. In this case FightCSV offers converters. The "Billable"
column seems to represent boolean values, so let's tackle that:

```ruby
class LogEntry
  include FightCSV::Record
  schema do
    field "Name"
    field "Client/Project", {
      identifier: :project
    }

    field "Billable", {
      converter: ->(string) { string == "yes" ? true : false }
    }
  end
end

```

Often when converting something, we assume that it has a certain format.
The "Date" column for example should always be of the format
```/\d{2}\.\d{2}\.\d{4}/```. A validation can easily be added to a column
with FightCSV:

```ruby
class LogEntry
  include FightCSV::Record
  schema do
    field "Name"
    field "Client/Project", {
      identifier: :project
    }

    field "Billable", {
      converter: ->(string) { string == "yes" ? true : false }
    }

    field "Date", {
      validate: /\d{2}\.\d{2}\.\d{4}/,
      converter: ->(string) { Date.parse(string) }
    }
  end
end
```

The complete schema:

```ruby
class LogEntry
  include FightCSV::Record
  schema do
    field "Name"
    field "Client/Project", {
      identifier: :project
    }

    field "Billable", {
      converter: ->(string) { string == "yes" ? true : false }
    }

    field "Date", {
      validate: /\d{2}\.\d{2}\.\d{4}/,
      converter: ->(string) { Date.parse(string) }
    }

    field "Tags", {
      converter: ->(string) { string.split(",") }
    }

    field "Minutes", {
      validate: /\d+/,
      converter: ->(string) { string.to_i }
    }
  end
end
```

## Parsing CSV

With the schema definition you're finally able to parse some CSV. There
are two possible ways of doing this:

1.  ```LogEntry.records``` will return an array with all rows
    mapped to instances of ```LogEntry```.

2.  ```LogEntry.import``` will return an enumerator which will pass the same ```LogEntry``` instance with the
    row changed for every iteration.

    ```ruby
    LogEntry.import(csv).map(&:minutes).reduce(:+)
    #=> 780
    ```
    Doing so you can avoid memory leaks on big csv documents.

## CSV without a header

Sometimes you may want to parse csv without a header. Instead of
defining how the column is called you can specify the number of the
column counting from left as an argument to field.

Consider the following CSV:
```
Ruby,object oriented
Scheme,functional
```

Now you can define a ```ProgrammingLanguage``` class like this:
```ruby
class ProgrammingLanguage
  include FightCSV::Record


  schema do
    csv_options = { header: false }
    field 1, identifier: :name
    field 2, identifier: :main_paradigm
  end
end
```

See the examples section for executable versions of these examples.


## Contributing to fight\_csv
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Manuel Korfmann. See LICENSE.txt for
further details.

