require 'csv'
module FightCSV
  class DataSource
    include Enumerable

    ALLOWED_OPTIONS = [:col_sep, :row_sep, :quote_char]

    constructable :io, readable: true
    constructable :csv_options,
      accessible: true,
      default: ->{ Hash.new }

    def each
      csv = CSV.new(self.io, Hash[csv_options.select { |opt| ALLOWED_OPTIONS.include? opt }])
      csv_options[:header] = true if csv_options[:header].nil?
      additions = {}
      additions[:header] = csv.shift if csv_options[:header]
      csv.each do |row|
        yield row, additions
      end
    end
  end
end
