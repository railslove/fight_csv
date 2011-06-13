module FightCSV
  module Record
    extend ActiveSupport::Concern

    module ClassMethods
      def csv_schema(filename = nil, &block)
        @csv_schema ||= Schema.new
        if String === filename
          @csv_schema.instance_eval { eval(File.read(filename)) }
        elsif block
          @csv_schema.instance_eval &block
        else
          @csv_schema
        end
      end
      def csv_from_parsed_data(array_of_csv_documents)
        array_of_csv_documents.map do |csv_document|
          csv_document[:body].map do |row|
            self.new(row, data_source: csv_document[:data_source])
          end
        end.flatten
      end

      def csv_from_files(filenames)
        csv_documents = Parser.from_files(filenames)
        csv_from_parsed_data(csv_documents)
      end

      def csv_from_file(filename)
        self.csv_from_files [filename]
      end
    end
    module InstanceMethods
      constructable [:data_source, required: true, accessible: true],
                    [:csv_schema, csv_validate_type: Schema, accessible: true]

      attr_reader :row

      def initialize(row, options = {})
        @row = Hash[self.data_source.header.zip row]
        @csv_schema ||= self.class.csv_schema
        super options
      end

      def csv_valid?
        self.csv_validate[:valid]
      end


      def csv_validate
        self.csv_schema.fields.inject({valid: true, errors: []}) do |csv_validation_hash, field|
          csv_validation_of_field = field.validate(row)
          csv_validation_hash[:valid] &&= csv_validation_of_field[:valid]
          csv_validation_hash[:errors].concat csv_validation_of_field[:errors] 
          csv_validation_hash
        end
      end

      def method_missing(meth, *args, &block)
        if meth =~ /^csv_/ && field = csv_schema.fields.find { |field| /#{field.identifier}(=)?/ === meth }
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

      def csv_set_attributes_hash
        instance_variable_set(:@attributes,Hash[self.csv_schema.fields.map do |field|
          [field.identifier.to_s,field.process(row)]
        end])
      end
    end
  end
end
