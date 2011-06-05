module FightCSV
	class Schema
		attr_accessor :fields
		def initialize
			self.fields = Array.new
		end

		def field(fieldname, constructor_hash)
			self.fields << Field.new(fieldname, constructor_hash)
		end
	end
end
