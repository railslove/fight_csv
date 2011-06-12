require 'helper'

describe 'ActiveRecord integration' do
  before do
    class ProgLang < ActiveRecord::Base
      include FightCSV::Record
    end
    ProgLang.schema fixture('prog_lang_schema.rb')
  end

  after do
    ProgLang.delete_all
  end

  it 'it allows constructing a record by using csv' do
    lang = ProgLang.new(['Python','', 'Guido van Rossum'], data_source: FightCSV::DataSource.new(header: ['Name', 'Paradigms', 'Creator']))
    lang.csv_to_attributes_ivar
    lang.save
    python  = ProgLang.find_by_name('Python')
    assert_equal 'Guido van Rossum', python.creator
  end

  it 'behaves like a normal active record object' do
    lang = ProgLang.new(['Python','', 'Guido van Rossum'], data_source: FightCSV::DataSource.new(header: ['Name', 'Paradigms', 'Creator']))
    lang.csv_to_attributes_ivar
    lang.save
    lang.name = 'Py'
    lang.save
    assert_equal 'Py', lang.reload.name
  end

  it 'allows creating multiple records with Records#from_file method' do
    langs = ProgLang.from_file fixture 'programming_languages.csv'
    langs.each(&:csv_to_attributes_ivar).each(&:save)
    assert_equal ['Ruby','Scheme','Brainfuck'], ProgLang.all.map(&:name)
  end

end
