module FightCSV
  class Record
    constructable [:data_source, required: true, accessible: true],
                  [:schema, validate_type: Schema, accessible: true]

    @@schema = nil

    attr_reader :row
    def self.from_parsed_data(array_of_csv_documents)
      array_of_csv_documents.map do |csv_document|
        csv_document[:body].map do |row|
          self.new(row, data_source: csv_document[:data_source])
        end
      end.flatten
    end

    def self.from_files(filenames)
      csv_documents = Parser.from_files(filenames)
      from_parsed_data(csv_documents)
    end

    def self.from_file(filename)
      self.from_files [filename]
    end

    def initialize(row)
      @row = self.data_source.header.zip row
      @schema ||= @@schema
    end

    def valid?
      self.validate[:valid]
    end

    def self.schema(filename = nil, &block)
      @@schema = Schema.new
      if String === filename
        @@schema.instance_eval { eval(File.read(filename)) }
      elsif block
        @@schema.instance_eval &block
      end
    end

    def validate
      self.schema.fields.inject({valid: true, errors: []}) do |validation_hash, field|
        validation_of_field = field.validate(row)
        validation_hash[:valid] &&= validation_of_field[:valid]
        validation_hash[:errors].concat validation_of_field[:errors] 
        validation_hash
      end
    end

    def method_missing(meth, *args, &block)
      if field = schema.fields.find { |field| field.identifier == meth }
        field.process(self.row)
      else
        super
      end
    end
  end
end
