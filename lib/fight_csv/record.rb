module FightCSV
  module Record

    def initalize(row, data_source)
      @data_source = data_source
    end

    def self.from_parsed_data(hash)
      hash[:body].map do |row|
        self.new(row, hash[:data_source])
      end
    end
  end
end
