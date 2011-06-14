require 'helper'
describe 'Record' do
  before do
    class Foo
      include  FightCSV::Record
    end
    @klass = Class.new.send(:include, FightCSV::Record)

    @schema = FightCSV::Schema.new
    @schema.field('Foo', identifier: :foo)
    @schema.field('Foz', identifier: :foz)
  end

  describe 'fields' do
    it 'aggregates fields using the dynamic attribute readers or hard coded readers' do
      @klass.class_eval { def foo; 1;end }
      record = @klass.new(['Bar','Baz'], schema: @schema, data_source: FightCSV::DataSource.new(header: ['Foo', 'Foz']))
      assert_equal({foo: 1, foz: 'Baz'}, record.fields)
    end
  end

  describe 'dynamic attributes' do
    describe 'readers' do
      it 'works' do
        record = @klass.new(['Bar','Baz'], schema: @schema, data_source: FightCSV::DataSource.new(header: ['Foo', 'Foz']))
        assert_equal 'Bar', record.foo
        assert_equal 'Baz', record.foz
      end

      it 'returns nil if the attribute is not defined' do
        record = @klass.new(['Bar'], schema: @schema, data_source: FightCSV::DataSource.new(header: ['Foo']))
        assert_equal 'Bar', record.foo
        assert_equal nil, record.foz
      end

      it 'converts values if necessary' do
        @schema.fields.find { |f| f.matcher == 'Foo' }.converter = proc { |value| value.downcase.to_sym }
        record = @klass.new(['Bar'], schema: @schema, data_source: FightCSV::DataSource.new(header: ['Foo']))
        assert_equal :bar, record.foo
      end
    end
    describe 'writers' do
      it 'allow write access to attributes in the row' do
        record = @klass.new(['Bar'], schema: @schema, data_source: FightCSV::DataSource.new(header: ['Foo']))
        record.foo = 4
        assert_equal 4, record.foo
      end

      it 'allows to write to fields defined in the schema but not provided through the csv document' do
        record = @klass.new([], schema: @schema, data_source: FightCSV::DataSource.new(header: []))
        record.foo = 4
        assert_equal 4, record.foo
      end
    end
  end


  describe 'from_files' do
    it 'reads in files, parses them and maps each row to a Record object' do
      records = Foo.from_files [fixture('programming_languages.csv')]
      assert_equal [['Name', 'Ruby'],
         ['Paradigms', 'object oriented,imperative,reflective,functional'],
         ['Creator', 'Yukihiro Matsumoto']], records.first.instance_variable_get(:@raw_row)
    end
  end

  describe 'shared test data' do
    before do
      records = Foo.from_parsed_data [{body: [%w{1 2 3},%w{2 3 4}], data_source: FightCSV::DataSource.new(header: ['a','b','c'])}]
      @record = records.first
      @record.schema = FightCSV::Schema.new.tap do |schema|
        converter = ->(value) { value.to_i }
        schema.field 'a', identifier: :a, converter: converter
        schema.field 'b', identifier: :b, converter: converter
        schema.field 'c', identifier: :c, converter: converter
      end
    end

    describe 'row' do
      it 'returns a hash with identifiers as keys and values as values' do
        assert_equal Hash[[[:a, 1],[:b,2],[:c,3]]], @record.row
      end
    end

    describe 'from_parsed_data' do
      it 'maps each row of csv to a record model' do
        assert_equal Hash[[[:a, 1], [:b, 2], [:c,3]]], @record.row
      end
    end
  end

  describe 'schema validation' do
    before do
      prog_lang_schema = fixture('prog_lang_schema.rb')
      @schema = FightCSV::Schema.new
      @schema.instance_eval { eval(File.read(prog_lang_schema)) }
      @prog_langs = Foo.from_parsed_data FightCSV::Parser.from_files([fixture('programming_languages.csv')])
      @prog_langs.each { |prog_lang| prog_lang.schema = @schema }
    end

    describe 'valid?' do
      it 'returns true if a record is valid' do
        assert_equal true, @prog_langs.all?(&:valid?)
      end
    end

    describe 'validate' do
      it 'returns a hash includind valid: true if the record is valid' do
        assert_equal({valid: true, errors: []}, @prog_langs.first.validate)
      end

      it 'returns a hash inlcuding valid: false and detailed error report' do
        @schema.fields.find { |f| f.identifier == :creator }.validator = /.+/
        data_source = FightCSV::DataSource.new(header: ['Name','Paradigms'])
        not_valid_hash = {
          valid: false,
          errors: [
            ':creator must match (?-mix:.+), but was ""'
        ]
        }
        assert_equal not_valid_hash,
          Foo.new(['LOLCODE','lolfulness',nil], data_source: data_source, schema: @schema).validate
      end
    end
  end

  describe 'schema' do
    it 'accepts a file name' do
      @klass.schema fixture('prog_lang_schema.rb')
      schema = @klass.schema
      assert_equal FightCSV::Schema, schema.class
      assert_equal 'Name', schema.fields.first.matcher
      assert_equal 'Creator', schema.fields.last.matcher
    end

    it 'also responds to a block' do
      @klass.schema do
        field 'Foo', identifier: :foo
      end

      schema = @klass.schema
      assert_equal 'Foo', schema.fields.first.matcher
    end
  end
end
