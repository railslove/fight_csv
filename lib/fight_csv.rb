$LOAD_PATH << File.dirname(File.expand_path(__FILE__))
require 'constructable'
require 'active_support'
require 'fight_csv/schema'
require 'fight_csv/parser'
require 'fight_csv/data_source'
require 'fight_csv/field'
require 'fight_csv/record'

module FightCSV
end
