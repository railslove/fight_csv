module FightCSV
  module Record
    extend ActiveSupport::Concern

    module ClassMethods
      def schema(filename = nil, &block)
        @schema ||= Schema.new
        if String === filename
          @schema.instance_eval { eval(File.read(filename)) }
        elsif block
          @schema.instance_eval &block
        else
          @schema
        end
      end
      def from_parsed_data(array_of_csv_documents)
        array_of_csv_documents.map do |csv_document|
          csv_document[:body].map do |row|
            self.new(row, data_source: csv_document[:data_source])
          end
        end.flatten
      end

      def from_files(filenames)
        csv_documents = Parser.from_files(filenames)
        from_parsed_data(csv_documents)
      end

      def from_file(filename)
        self.from_files [filename]
      end
    end
    module InstanceMethods
      constructable [:data_source, required: true, accessible: true],
                    [:schema, csv_validate_type: Schema, accessible: true]

      attr_reader :row

      def initialize(row, options = {})
        @row = Hash[self.data_source.header.zip row]
        @schema ||= self.class.schema
        super options
      end

      def csv_valid?
        self.csv_validate[:valid]
      end


      def csv_validate
        self.schema.fields.inject({valid: true, errors: []}) do |csv_validation_hash, field|
          csv_validation_of_field = field.validate(row)
          csv_validation_hash[:valid] &&= csv_validation_of_field[:valid]
          csv_validation_hash[:errors].concat csv_validation_of_field[:errors] 
          csv_validation_hash
        end
      end

      def method_missing(meth, *args, &block)
        if field = schema.fields.find { |field| /#{field.identifier}(=)?/ === meth }
          if $1 == '='
            key = field.match(row).first
            row[key] = args.first
          else
            field.process(self.row)
          end
        else
          super
        end
      end

      def csv_to_attributes_ivar
        instance_variable_set(:@attributes,Hash[self.schema.fields.map do |field|
          [field.identifier.to_s,field.process(row)]
        end])
      end
    end
  end
end
