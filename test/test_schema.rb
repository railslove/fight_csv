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
  end
end
