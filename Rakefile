# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "fight_csv"
  gem.homepage = "http://github.com/mkorfmann/fight_csv"
  gem.license = "MIT"
  gem.summary = %Q{JSON-Schema + ActiveModel for CSV}
  gem.description = %Q{
Provides a nice DSL to describe your CSV document.
CSV documents can be validated against this description.
You can easily define types like Integer or Array for CSV through converters.
}
  gem.email = "manu@korfmann.info"
  gem.authors = ["Manuel Korfmann"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


task :default => :test
