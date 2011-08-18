require 'csv'
module FightCSV
  class DataSource
    include Enumerable

    ALLOWED_OPTIONS = [:col_sep, :row_sep, :quote_char]

    constructable :header, default: ->{true}, readable: true
    constructable :io, readable: true
    constructable :csv_options,
      accessible: true,
      default: ->{ Hash.new }

    def each
      csv = CSV.new(self.io, Hash[csv_options.select { |opt| ALLOWED_OPTIONS.include opt }])
      additions = {}
      additions[:header] = csv.shift if self.header
      csv.each do |row|
        yield row, additions
      end
    end
  end
end
