require 'helper'
describe 'Schema' do
  describe 'DSL' do
    it 'allows to easily create a field' do
      schema = FightCSV::Schema.new
      converter = ->(value) { value.upcase }

      schema.field "Name", {
        converter: converter,
        validator: /\w*/,
        identifier: :name
      }

      field = schema.fields.first
      assert_equal converter, field.converter
      assert_equal /\w*/, field.validator
    end

    it 'accepts a file name' do
      schema = Schema.new fixture('prog_lang_schema.rb')
      assert_equal FightCSV::Schema, schema.class
      assert_equal 'Name', schema.fields.first.matcher
      assert_equal 'Creator', schema.fields.last.matcher
    end

    it 'also responds to a block' do
      schema = Schema.new do
        field 'Foo', identifier: :foo
      end

      assert_equal 'Foo', schema.fields.first.matcher
    end
  end
end
