require '../lib/fight_csv'
csv = <<-CSV
Date,Person,Client/Project,Minutes,Hours,Tags,Description,Billable,Invoiced,Invoice Reference
2011-08-15,Manuel Korfmann,railslove,60,1.0,blogpost,"",yes,no,
2011-08-15,Manuel Korfmann,railslove,60,1.0,meeting,"",yes,no,
2011-08-15,Manuel Korfmann,reports,180,3.0,"concepting, research","",yes,no,
2011-08-15,Manuel Korfmann,heidelberry,60,1.0,"meeting, research","",yes,no,
2011-08-15,Manuel Korfmann,charts,60,1.0,coding,"",yes,no,
2011-08-08,Michael Bumann,salesking,60,1.0,ec2 downtime,"",yes,no,
2011-08-05,Tim  Schneider,persofaktum,60,1.0,inquiries#edit issue,"",yes,no,
2011-08-05,Michael Bumann,salesking,210,3.5,brainstorming+besprechung kpis,"",yes,no,
2011-08-03,Lars Brillert,Avocado Store,105,1.75,importer,tkgp kids,yes,no,
2011-08-02,Tim  Schneider,salesking,90,1.5,boarding process,"",yes,no,
2011-08-02,Lars Brillert,Avocado Store,120,2.0,feature development,kriterienfilter und badges,yes,no,
2011-08-02,Lars Brillert,Avocado Store,165,2.75,operations,price delimiter; server fix; redirects,yes,no,
2011-08-01,Mike Poltyn,time2king,120,2.0,"refactoring, testing","",yes,no,
2011-08-01,Jan  Kus,salesking,360,6.0,"*unbillable, notartermin","",yes,no,
2011-08-01,Tim  Schneider,lysbon,270,4.5,"coding, stuff bumper","",yes,no,
2011-08-01,Lars Brillert,Avocado Store,180,3.0,"export, ticket work","",yes,no,
CSV

class LogEntry
  include FightCSV::Record
  schema do
    field "Date", {
      converter: ->(string) { Date.parse(string) },
      identifier: :date
    }

    field "Name", {
      identifier: :name,
    }

    field "Minutes", {
      identifier: :minutes,
      converter: ->(string) { string.to_i }
    }

    field "Billable", {
      identifier: :billable,
      converter: ->(string) { string == "yes" ? true : false }
    }
  end
end


records = LogEntry.records csv
puts records.map(&:minutes).reduce(&:+)
