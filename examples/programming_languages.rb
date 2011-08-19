require '../lib/fight_csv'

csv = <<CSV
Ruby,object oriented
Scheme,functional
CSV

class ProgrammingLanguage
  include FightCSV::Record


  schema do
    csv_options header: false
    field 1, identifier: :name
    field 2, identifier: :main_paradigm
  end
end

puts ProgrammingLanguage.records(csv).map(&:name)
