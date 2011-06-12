require 'helper'
require 'set'

describe 'Field' do
  describe 'initialize' do
    it 'sets the matcher for matching csv fields' do
      field = FightCSV::Field.new(/Field/, identifier: :field)
      assert_equal /Field/, field.matcher
    end
  end

  describe 'validate' do
    before do
      @field = FightCSV::Field.new(/(Git-Hash)|(Commit-Hash)/,required: true, validator: /[a-z0-9]{5}/, identifier: :git_hash)
    end

    it 'checks for every property, returns {valid: true} if valid' do
      assert_equal({valid: true, errors: []}, @field.validate([["Git-Hash", "12abc"]]))
    end

    it 'returns detailed error information if invalid(validate)' do
      assert_equal({valid: false, errors: ["Value of :git_hash must match (?-mix:[a-z0-9]{5}), but was foo"]},
                   @field.validate([["Git-Hash", "foo"]]))
    end

    it 'checks for existence if field is required(no match)' do
      assert_equal({errors: [':git_hash is a required field'], valid: false},
                   @field.validate([%{a b}]))

    end

    it 'also accepts a proc as a validator(not valid)' do
      @field.validator = ->(git_hash) { git_hash === /[a-z0-9]{5}/ }
      assert_equal({valid: false, errors: ["Value of :git_hash must pass #{@field.validator.inspect}, but was foo"]},
                   @field.validate([["Git-Hash", "foo"]]))
    end

    it 'also accepts a proc as a validator(not valid)' do
      @field.validator = ->(git_hash) { /[a-z0-9]{5}/ === git_hash  }
      assert_equal({valid: true, errors: []},
                   @field.validate([["Git-Hash", "5oa9c"]]))
    end
  end

  describe 'match' do
    it 'retuns only one element, if only one element was found' do
      field = FightCSV::Field.new('Foo', identifier: :foo)
      row = [['Bar','6'],['Foo','7']]
      assert_equal ['Foo', '7'], field.match(row)
    end
  end

  describe 'process' do
    it 'returns a match if it finds andy' do
      field = FightCSV::Field.new('Foo', identifier: :foo)
      row = [['Bar','6'],['Foo','7']]
      assert_equal '7', field.process(row)
    end

    it 'returns nil if it doesnt find a match' do
      field = FightCSV::Field.new('Foo', identifier: :foo)
      row = [['Bar','6']]
      assert_equal nil, field.process(row)
    end

    it 'converts a value if necessary' do
      field = FightCSV::Field.new('Foo', identifier: :foo, converter: proc { |value| value.to_i ** 2 })
      row = [['Foo','6']]
      assert_equal 36, field.process(row)
    end

    it 'does not try to convert a value, if it didn\'t pass validation' do
      field = FightCSV::Field.new('Foo', identifier: :foo, converter: proc { |value| value ** 2 })
      row = [['Foo', nil]]
      assert_equal nil, field.process(row)
    end
  end
end
