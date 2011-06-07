require 'helper'
describe 'Record' do
  before do
    class ProgrammingLanguage < FightCSV::Record
    end
  end
  describe 'from parsed data' do
    it 'maps each row of csv to a record model' do
      records = ProgrammingLanguage.from_parsed_data [{body: [%w{1 2 3},%w{2 3 4}], data_source: FightCSV::DataSource.new(header: ['a','b','c'])}]
      assert_equal %w{1 2 3}, records.first.row
      assert_equal %w{a b c}, records.last.data_source.header
    end
  end

  describe 'schema validation' do
    before do
      ProgrammingLanguage.instance_variable_set(:@schema, FightCSV::Schema.new { load(fixture('prog_lang_schema.rb')) })
      @prog_langs = ProgrammingLanguage.from_parsed_data FightCSV::Parser.from_files([fixture('programming_languages.csv')])
    end

    describe 'valid?' do
      it 'returns true if a record is valid' do
        assert_equal true, @prog_langs.all?(&:valid?)
      end
    end

    describe 'validate' do
      it 'returns a hash includind valid: true if the record is valid' do
        assert_equal({valid: true}, @prog_langs.first.validate)
      end
    end
  end
end
