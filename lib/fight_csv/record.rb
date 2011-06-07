module FightCSV
  class Record

    attr_accessor :row
    constructable [:data_source, required: true, accessible: true]

    def self.from_parsed_data(array_of_csv_documents)
      array_of_csv_documents.map do |csv_document|
        csv_document[:body].map do |row|
          self.new(row, data_source: csv_document[:data_source])
        end
      end.flatten
    end

    def initialize(row)
      @row = row
    end

    def valid?
      self.validate[:valid]
    end

    def validate
      { valid: true }
    end
  end
end
