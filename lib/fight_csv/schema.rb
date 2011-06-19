module FightCSV
	class Schema
		attr_accessor :fields
		def initialize(filename = nil, &block)
			self.fields = Array.new
      if String === filename
        self.instance_eval { eval(File.read(filename)) }
      elsif block
        self.instance_eval &block
      end
		end

		def field(fieldname, constructor_hash)
			self.fields << Field.new(fieldname, constructor_hash)
		end
	end
end
