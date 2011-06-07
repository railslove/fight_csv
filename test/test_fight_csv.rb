require 'helper'

describe 'Integration' do
  before do
    schema_file = fixture('schema.rb')
    ProgrammingLanguage = Class.new(FightCSV::Record) do
      schema schema_file
    end

    programming_languages = ProgrammingLanguage.from_file fixture('programming_languages.rb')
  end

  it 'can validate a csv document' do
    assert_equal true, programming_languages.all? { |programming_language| programming_language.valid? }
  end

  it 'converts fields of a csv document' do
    ruby = programming_languages.select { |prog_lang| prog_lang.name == 'ruby' }
    assert_equal ['object oriented', 'imperative', 'reflective', 'functional'], ruby.paradigms
  end
end
