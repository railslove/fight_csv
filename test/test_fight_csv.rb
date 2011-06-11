require 'helper'


describe 'Integration' do
  before do

    schema_file = fixture('prog_lang_schema.rb')
    ProgrammingLanguage ||= Class.new(FightCSV::Record) do
      schema schema_file
    end

    @programming_languages = ProgrammingLanguage.from_file fixture('programming_languages.csv')
  end

  it 'can validate a csv document' do
    assert_equal true, @programming_languages.all? { |programming_language| programming_language.valid? }
  end

  it 'converts fields of a csv document and provides dynamic attribut readers' do
    ruby = @programming_languages.find { |prog_lang| prog_lang.name == 'Ruby' }
    assert_equal ['object oriented', 'imperative', 'reflective', 'functional'], ruby.paradigms
  end
end
