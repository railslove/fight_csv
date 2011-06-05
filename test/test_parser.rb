require 'helper'
describe 'Parser' do

  describe 'from_string' do
    before do
      @csv = 'foo;bar;foz;b4z;"foo;bar"/2;4;5;no;o/lala;bla;woot;fuck;o'
    end
    describe 'costum seperators' do
      it "extracts the header" do
        assert_equal %w{foo bar foz b4z foo;bar}, FightCSV::Parser.from_string(@csv, seperator: ';', dataset_seperator:'/').first[:data_source].header
      end

      it 'returns an array with a hash including the body of the csv + metadata' do
        parsed = FightCSV::Parser.from_string(@csv, seperator: ';', dataset_seperator: '/')
        assert_equal nil, parsed.first[:data_source].filename
        assert_equal %w{2 4 5 no o}, parsed.first[:body].first
      end
    end
  end

  describe 'from_files' do
    it "contains metadata about the filename" do
      data = FightCSV::Parser.from_files([fixture('recipes.csv'), fixture('cocktails.csv')])
      assert_match 'recipes.csv', data.first[:data_source].filename
      assert_match 'cocktails.csv', data.last[:data_source].filename
    end
  end
end
