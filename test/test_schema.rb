require 'helper'
describe 'Schema' do
  describe 'DSL' do
    it 'allows to easily create a field' do
      schema = FightCSV::Schema.new
      converter = ->(value) { value.upcase }

      schema.field "Name", {
        required: true,
        converter: converter,
        validator: /\w*/
      }

      field = schema.fields.first
      assert_equal true, field.required
      assert_equal converter, field.converter
      assert_equal /\w*/, field.validator
    end
  end
end
