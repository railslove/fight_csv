require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'active_record'
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => ":memory:"
)


ActiveRecord::Schema.define do
  create_table :prog_langs do |table|
      table.column :name, :string
      table.column :creator, :string
      table.column :paradigms, :string
  end
end

require 'simplecov'
SimpleCov.start do
  add_filter 'test'
  add_filter 'help'
end

require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'fight_csv'

class MiniTest::Unit::TestCase
	def fixture(filename)
		File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', filename)
	end

	def refute_raises
		test = -> do
			begin	
				yield
			rescue => e
				return false, e
			else
				true
			end
		end
		boolean, exception = test.call
		assert boolean, "Expected no exception, but got #{exception}"
	end
end
