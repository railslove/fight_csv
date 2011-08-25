require 'helper'
describe 'Record' do
  before do
    @klass = Class.new do
      include FightCSV::Record
    end
    @schema = FightCSV::Schema.new do
      field('Foo', identifier: :foo)
      field('Foz', identifier: :foz)
    end
    @klass.schema = @schema
  end

  describe 'schema=' do
    it 'automatically refreshes the row' do
      instance = @klass.new(%w{bar baz}, header: %w{Bar Foz})
      instance.schema = FightCSV::Schema.new do
        field('Bar', identifier: :bar)
      end
      assert_equal({ bar: 'bar' }, instance.row)
    end
  end

  describe 'records' do
    it 'maps each row to a record object' do
      records = @klass.records("Foo,Foz\nbar,baz\nfoo,foz")
      assert records.all? { |r| Record === r }
      assert_equal 'bar', records.first.foo
    end

    it 'takes default csv_options from schema' do
      @schema.csv_options[:col_sep] = "|"
      records = @klass.records("Foo|Foz\nbar|baz\nfoo|foz")
      assert_equal 'bar', records.first.foo
    end

    it 'is possible to override default schema csv_options' do
      @schema.csv_options[:col_sep] = "|"
      records = @klass.records("Foo;Foz\nbar;baz\nfoo;foz", col_sep: ';')
      assert_equal 'bar', records.first.foo
    end

    it 'is possible to omit the header' do
      @schema.fields = []
      @schema.field 1, identifier: :foo
      @schema.field 2, identifier: :bar
      @schema.csv_options[:header] = false
      records = @klass.records("bar;baz\nfoo;foz", col_sep: ';')
      assert_equal 'bar', records.first.foo
    end
  end

  describe 'import' do
    it 'provides an enumerator for iterating over the csv reusing the same record object' do
      enum = @klass.import("Foo,Foz\nbar,baz\nfoo,foz")
      assert enum.map(&:object_id).each_cons(2).all? { |a,b| a == b }, 'Expected all records to be the same object'
      assert_equal({foo: 'bar', foz: 'baz'}, enum.first.row)
    end
  end

  describe 'fields' do
    it 'aggregates fields using the dynamic attribute readers or hard coded readers' do
      @klass.class_eval { def foo; 1;end }
      record = @klass.new(['Bar','Baz'], schema: @schema, header: ['Foo', 'Foz'])
      assert_equal({foo: 1, foz: 'Baz'}, record.fields)
    end
  end

  describe 'dynamic attributes' do
    describe 'readers' do
      it 'works' do
        record = @klass.new(['Bar','Baz'], schema: @schema, header: ['Foo', 'Foz'])
        assert_equal 'Bar', record.foo
        assert_equal 'Baz', record.foz
      end

      it 'returns "" if the attribute is not defined' do
        record = @klass.new(['Bar'], schema: @schema, header: ['Foo'])
        assert_equal 'Bar', record.foo
        assert_equal nil, record.foz
      end

      it 'converts values if necessary' do
        @schema.fields.find { |f| f.matcher == 'Foo' }.converter = proc { |value| value.downcase.to_sym }
        record = @klass.new(['Bar'], schema: @schema,header: ['Foo'])
        assert_equal :bar, record.foo
      end
    end

    describe 'writers' do
      it 'allow write access to attributes in the row' do
        record = @klass.new(['Bar'], schema: @schema, header: ['Foo'])
        record.foo = 4
        assert_equal 4, record.foo
      end

      it 'allows to write to fields defined in the schema but not provided through the csv document' do
        record = @klass.new([], schema: @schema,header: [])
        record.foo = 4
        assert_equal 4, record.foo
      end
    end
  end

  describe 'shared test data' do
    before do
      @class = Class.new { include FightCSV::Record }
      @class.schema  do
        converter = ->(value) { value.to_i }
        field 'a', identifier: :a, converter: converter
        field 'b', identifier: :b, converter: converter
        field 'c', identifier: :c, converter: converter
      end
      @record = @class.new %w{1 2 3}, header: ['a','b','c']
    end

    describe 'row' do
      it 'returns a hash with identifiers as keys and values as values' do
        assert_equal Hash[[[:a, 1],[:b,2],[:c,3]]], @record.row
      end
    end
  end

  describe 'schema validation' do
    before do
      prog_lang_schema = fixture('prog_lang_schema.rb')
      @prog_lang = Class.new do
        include FightCSV::Record
        schema prog_lang_schema
      end
      @prog_langs = @prog_lang.records(File.open(fixture('programming_languages.csv')))
    end

    describe 'valid?' do
      it 'returns true if a record is valid' do
        assert_equal true, @prog_langs.all?(&:valid?)
      end
    end

    describe 'errors' do
      it 'returns a hash includind valid: true if the record is valid' do
        assert_equal({valid: true, errors: []}, @prog_langs.first.validate)
      end

      it 'returns a hash inlcuding valid: false and detailed error report' do
        @prog_lang.schema.fields.find { |f| f.identifier == :creator }.validator = /.+/
        errors = [ ':creator must match (?-mix:.+), but was ""']
        instance = @prog_lang.new(['LOLCODE','lolfulness',nil], header: ['Name','Paradigms'])
        assert_equal false, instance.valid?
        assert_equal errors, instance.errors
      end
    end
  end
end
