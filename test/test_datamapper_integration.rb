require 'helper'
require 'data_mapper'
describe 'DataMapper Integration' do
  before do
    DataMapper::setup(:default, 'sqlite3::memory:')
    class ProgrammingLanguage
      include FightCSV::Record
      include DataMapper::Resource

      property :id, Serial
      property :name, String
      property :creator, String
      property :paradigms, String
    end
    ProgrammingLanguage.auto_migrate!
    ProgrammingLanguage.csv_schema fixture('prog_lang_schema.rb')
  end

  it 'it allows constructing a record by using csv' do
    lang = ProgrammingLanguage.construct_from_row(['Python','', 'Guido van Rossum'], data_source: FightCSV::DataSource.new(header: ['Name', 'Paradigms', 'Creator']))
    lang.csv_set_attributes_hash
    lang.save
    python  = ProgrammingLanguage.find(name: 'Python').first
    assert_equal 'Guido van Rossum', python.creator
  end

  it 'behaves like a normal data mapper object' do
    lang = ProgrammingLanguage.construct_from_row(['Python','', 'Guido van Rossum'], data_source: FightCSV::DataSource.new(header: ['Name', 'Paradigms', 'Creator']))
    lang.csv_set_attributes_hash
    lang.save
    lang.name = 'Py'
    lang.save
    assert_equal 'Py', lang.reload.name
  end

  it 'allows creating multiple records with Records#from_file method' do
    langs = ProgrammingLanguage.csv_from_file fixture 'programming_languages.csv'
    langs.each(&:csv_set_attributes_hash).each(&:save)
    assert_equal ['Ruby','Scheme','Brainfuck'], ProgrammingLanguage.all.map(&:name)
  end

end
