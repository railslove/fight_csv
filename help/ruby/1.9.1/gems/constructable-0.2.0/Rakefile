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
  gem.name = "constructable"
  gem.homepage = "http://github.com/mkorfmann/constructable"
  gem.license = "MIT"
  gem.summary = %Q{Makes constructing objects through an attributes hash easier}
  gem.description = %Q{
Adds the class macro Class#constructable to easily define what attributes a Class accepts provided as a hash to Class#new.
Attributes can be configured in their behaviour in case they are not provided or are in the wrong format.
Their default value can also be defined and you have granular control on how accessible your attribute is.
See the documentation for Constructable::Constructable#constructable or the README for more information.
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
