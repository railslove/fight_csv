describe 'Record' do
  describe 'initalize' do
    it 'should map it\'s row representation to the header' do
      record = Record.new(['Superman', 'Can Fly'], DataSource.new({header: ['Superhero', 'Abilities']}))
    end
  end
end
