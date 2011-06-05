require 'helper'

describe 'Field' do
  describe 'initialize' do
    it 'sets the matcher for matching csv fields' do
      field = FightCSV::Field.new(/Field/)
      assert_equal /Field/, field.matcher
    end
  end
end
