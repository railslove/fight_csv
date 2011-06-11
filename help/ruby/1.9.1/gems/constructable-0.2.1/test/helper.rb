require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'simplecov'
SimpleCov.start do
  add_filter 'test'
end

require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'constructable'

class MiniTest::Unit::TestCase
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
