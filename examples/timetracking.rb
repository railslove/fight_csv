require '../lib/fight_csv'

csv = <<-CSV
Date,Person,Client/Project,Minutes,Tags,Billable
2011-08-15,John Doe,handsomelabs,60,blogpost,no
2011-08-15,Max Powers,beerbrewing,60,meeting,yes
2011-08-15,Tyler Durden,babysitting,180,"concepting, research",yes
2011-08-15,Hulk Hero,gardening,60,"meeting, research",no
2011-08-15,John Doe,handsomelabs,60,coding,yes
2011-08-08,John Doe,handsomelabs,60,"blabla, meeting",yes
CSV

class LogEntry
  include FightCSV::Record
  schema do
    field "Person"
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


records = LogEntry.records csv

# Persons who have worked on billable projects
billable_entries = records.select(&:billable)
puts billable_entries.map(&:person).uniq.join(" - ")
