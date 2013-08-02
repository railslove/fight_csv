require 'csv'
module FightCSV
  class DataSource
    include Enumerable

    ALLOWED_OPTIONS = [:col_sep, :row_sep, :quote_char]

    attr_accessor :io
    attr_reader :csv_options

    def csv_options=(csv_options)
      @csv_options = csv_options || ->{ Hash.new }
    end

    def initialize(options ={})
      @io = options[:io]
      @csv_options = options[:csv_options] || ->{ Hash.new }
    end

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
