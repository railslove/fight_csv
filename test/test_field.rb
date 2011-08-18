require 'helper'
require 'set'

describe 'Field' do
  describe 'initialize' do
    it 'sets the matcher for matching csv fields' do
      field = FightCSV::Field.new(/Field/, identifier: :field)
      assert_equal /Field/, field.matcher
    end
  end

  describe 'identifier' do
    it 'defaults to the matcher downcase' do
      field = FightCSV::Field.new("Field")
      assert_equal field.identifier, :field
    end

    it 'raises an error if nor a identifier is present neither the matcher is a string' do
      field = FightCSV::Field.new(5)
      assert_raises ArgumentError do
        field.identifier
      end
    end
  end

  describe 'ivar_symbol' do
    it 'returns the identifier as an ivar symbol' do
      field = FightCSV::Field.new(/Field/, identifier: :field)
      assert_equal :@field, field.ivar_symbol
    end
  end

  describe 'validate' do
    before do
      @field = FightCSV::Field.new(/(Git-Hash)|(Commit-Hash)/,required: true, validator: /[a-z0-9]{5}/, identifier: :git_hash)
    end

    it 'checks for every property, returns {valid: true} if valid' do
      assert_equal({valid: true}, @field.validate(['12abc'], ['Git-Hash']))
    end

    it 'returns detailed error information if invalid(validate)' do
      assert_equal({valid: false, error: ":git_hash must match (?-mix:[a-z0-9]{5}), but was \"foo\""},
                   @field.validate(['foo'], ['Git-Hash']))
    end

    it 'also accepts a proc as a validator(not valid)' do
      @field.validator = ->(git_hash) { git_hash === /[a-z0-9]{5}/ }
      assert_equal({valid: false, error: ":git_hash must pass #{@field.validator}, but was \"foo\""},
                   @field.validate(['foo'],['Git-Hash']))
    end

    it 'also accepts a proc as a validator(not valid)' do
      @field.validator = ->(git_hash) { /[a-z0-9]{5}/ === git_hash  }
      assert_equal({valid: true},
                   @field.validate(['5oa9c'],['Git-Hash']))
    end
  end

  describe 'match' do
    before do
      @row = ['6','7']
    end
    describe 'not an integer' do
      before do
        @field = FightCSV::Field.new('Foo', identifier: :foo)
      end

      it 'returns an element, whose header matches the matcher' do
        header = ['Foo', 'Bar']
        assert_equal '6', @field.match(@row, header)
      end

      it 'raises an ArgumentError, if no header is provided' do
        assert_raises ArgumentError do
          @field.match(@row)
        end
      end
    end

    describe 'an integer' do
      it 'returns the element, with the index == matcher - 1' do
        field = FightCSV::Field.new(1, identifier: :foo)
        assert_equal '6', field.match(@row)
      end
    end
  end

  describe 'process' do
    before do
      @field = FightCSV::Field.new('Foo', identifier: :foo)
    end

    it 'raises an ArgumentError if no header is present, and the matcher isn\'t an Integer' do
      assert_raises ArgumentError do
        @field.process(['bla'])
      end
    end

    it 'returns a match if one is present' do
      row = ['6','7']
      header = ['Bar','Foo']
      assert_equal '7', @field.process(row, header)
    end

    it 'returns "" if it doesnt find a match' do
      row = ['6']
      header = ['Bar']
      assert_equal nil, @field.process(row, header)
    end

    it 'converts a value if necessary' do
      @field.converter = proc { |value| value.to_i ** 2 }
      row = ['6']
      header = ['Foo']
      assert_equal 36, @field.process(row, header)
    end
  end
end
