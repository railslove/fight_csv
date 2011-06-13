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
      def from_parsed_data(array_of_documents)
        array_of_documents.map do |document|
          document[:body].map do |row|
            self.new(row, data_source: document[:data_source])
          end
        end.flatten
      end

      def from_files(filenames)
        documents = Parser.from_files(filenames)
        from_parsed_data(documents)
      end

      def from_file(filename)
        self.from_files [filename]
      end
    end
    module InstanceMethods
      constructable [:data_source, required: true, accessible: true],
                    [:schema, validate_type: Schema, accessible: true]

      attr_reader :row

      def initialize(row, options = {})
        @row = Hash[self.data_source.header.zip row]
        @schema ||= self.class.schema
        super options
      end

      def valid?
        self.validate[:valid]
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
        if meth =~ /^/ && field = schema.fields.find { |field| /#{field.identifier}(=)?/ === meth }
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

      #def set_attributes_hash
      #  instance_variable_set(:@attributes,Hash[self.schema.fields.map do |field|
      #    [field.identifier.to_s,field.process(row)]
      #  end])
      #end
    end
  end
end
