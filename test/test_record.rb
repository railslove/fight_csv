require 'helper'
describe 'Record' do
  before do
    class ProgrammingLanguage < FightCSV::Record
    end
  end

  describe 'dynamic attributes' do
    before do 
      @schema = FightCSV::Schema.new
      @schema.field('Foo', identifier: :foo)
      @schema.field('Foz', identifier: :foz)
    end

    describe 'readers' do
      it 'works' do
        record = FightCSV::Record.new(['Bar','Baz'], schema: @schema, data_source: FightCSV::DataSource.new(header: ['Foo', 'Foz']))
        assert_equal 'Bar', record.foo
        assert_equal 'Baz', record.foz
      end

      it 'returns nil if the attribute is not defined' do
        record = FightCSV::Record.new(['Bar'], schema: @schema, data_source: FightCSV::DataSource.new(header: ['Foo']))
        assert_equal 'Bar', record.foo
        assert_equal nil, record.foz
      end

      it 'converts values if necessary' do
        @schema.fields.find { |f| f.matcher == 'Foo' }.converter = proc { |value| value.downcase.to_sym }
        record = FightCSV::Record.new(['Bar'], schema: @schema, data_source: FightCSV::DataSource.new(header: ['Foo']))
        assert_equal :bar, record.foo
      end
    end
    describe 'writers' do
      it 'allow write access to attributes in the row' do
        record = FightCSV::Record.new(['Bar'], schema: @schema, data_source: FightCSV::DataSource.new(header: ['Foo']))
        record.foo = 4
        assert_equal 4, record.foo
      end
    end
  end

  describe 'row' do
    it 'should zip the actual row and the header' do
      records = ProgrammingLanguage.from_parsed_data [{body: [%w{1 2 3},%w{2 3 4}], data_source: FightCSV::DataSource.new(header: ['a','b','c'])}]
      assert_equal [['a', '1'],['b','2'],['c','3']], records.first.row
    end
  end

  describe 'from_files' do
    it 'reads in files, parses them and maps each row to a Record object' do
      records = ProgrammingLanguage.from_files [fixture('programming_languages.csv')]
      assert_equal [['Name', 'Ruby'],['Paradigms', 'object oriented,imperative,reflective,functional'],['Creator', 'Yukihiro Matsumoto']], records.first.row
    end
  end

  describe 'from_parsed_data' do
    it 'maps each row of csv to a record model' do
      records = ProgrammingLanguage.from_parsed_data [{body: [%w{1 2 3},%w{2 3 4}], data_source: FightCSV::DataSource.new(header: ['a','b','c'])}]
      assert_equal [%w{a 1}, %w{b 2}, %w{c 3}], records.first.row
    end
  end

  describe 'schema csv_validation' do
    before do
      prog_lang_schema = fixture('prog_lang_schema.rb')
      @schema = FightCSV::Schema.new
      @schema.instance_eval { eval(File.read(prog_lang_schema)) }
      @prog_langs = ProgrammingLanguage.from_parsed_data FightCSV::Parser.from_files([fixture('programming_languages.csv')])
      @prog_langs.each { |prog_lang| prog_lang.schema = @schema }
    end

    describe 'csv_valid?' do
      it 'returns true if a record is csv_valid' do
        assert_equal true, @prog_langs.all?(&:csv_valid?)
      end
    end

    describe 'csv_validate' do
      it 'returns a hash includind csv_valid: true if the record is valid' do
        assert_equal({valid: true, errors: []}, @prog_langs.first.csv_validate)
      end

      it 'returns a hash inlcuding csv_valid: false and detailed error report' do
        data_source = FightCSV::DataSource.new(header: ['Name','Paradigms'])
        not_csv_valid_hash = {
          valid: false,
          errors: [
            ":creator is a required field"
        ]
        }
        assert_equal not_csv_valid_hash,
          ProgrammingLanguage.new(['LOLCODE','lolfulness',nil], data_source: data_source, schema: @schema).csv_validate
      end
    end
  end

  describe 'schema' do
    before do
      @klass = Class.new(FightCSV::Record)
    end

    it 'accepts a file name' do
      @klass.schema fixture('prog_lang_schema.rb')
      schema = @klass.class_variable_get(:@@schema)
      assert_equal FightCSV::Schema, schema.class
      assert_equal 'Name', schema.fields.first.matcher
      assert_equal 'Creator', schema.fields.last.matcher
    end

    it 'also responds to a block' do
      @klass.schema do
        field 'Foo', required: true, identifier: :foo
      end

      schema = @klass.class_variable_get(:@@schema)
      assert_equal 'Foo', schema.fields.first.matcher
      assert_equal true, schema.fields.first.required
    end
  end
end
