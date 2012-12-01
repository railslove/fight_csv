module FightCSV
  module Record
    extend ActiveSupport::Concern

    module ClassMethods
      def schema=(schema)
        @schema = schema
      end

      def records(io, csv_options = {})
        data_source = DataSource.new(io: io, csv_options: @schema.csv_options.merge(csv_options))
        data_source.map { |row,additions|self.new(row, additions) }
      end

      def import(io, csv_options = {})
        Enumerator.new do |yielder|
          record = self.new
          data_source = DataSource.new(io: io, csv_options: @schema.csv_options.merge(csv_options))
          data_source.each do |row, additions|
            record.header = additions[:header]
            record.row = row
            yielder << record
          end
        end
      end

      def schema(filename = nil, &block)
        if filename || block
          @schema = Schema.new(filename, &block) 
        else
          @schema
        end
      end
    end

    attr_reader :schema
    attr_accessor :header

      attr_accessor :row
      attr_reader :errors


      def initialize(row = nil,options = {})
        @schema = options[:schema]
        @header = options[:header]
        @schema ||= self.class.schema
        self.row = row if row
      end

      def row=(raw_row)
        @raw_row = raw_row
        @row = Hash[self.schema.fields.map { |field| [field.identifier,field.process(@raw_row, @header)] }]
      end

      def fields
        Hash[schema.fields.map { |field| [field.identifier, self.send(field.identifier)] }]
      end

      def schema=(schema)
        @schema=schema
        self.row = @raw_row
      end

      def valid?
        validation = self.validate
        @errors = validate[:errors]
        validation[:valid]
      end

      def validate
        self.schema.fields.inject({valid: true, errors: []}) do |validation_hash, field|
          validation_of_field = field.validate(@raw_row, @header)
          validation_hash[:valid] &&= validation_of_field[:valid]
          validation_hash[:errors] << validation_of_field[:error] if validation_of_field[:error]
          validation_hash
        end
      end

      def method_missing(meth, *args, &block)
        if field = schema.fields.find { |field| /#{field.identifier}(=)?/ === meth }
          if $1 == '='
            @row[field.identifier] = args.first
          else
            @row[field.identifier]
          end
        else
          super
        end
      end
  end
end
