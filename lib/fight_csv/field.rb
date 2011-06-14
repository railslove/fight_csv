module FightCSV
  class Field
    constructable [:converter, validate_type: Proc, accessible: true],
                  [:identifier, validate_type: Symbol, accessible: true, required: true],
                  [:validator, accessible: true, default: /.*/ ]

    attr_accessor :matcher

    def initialize(matcher, options = {})
      @matcher = matcher
    end

    def validate(row)
      match = self.match(row).to_s
      if self.validator.respond_to?(:call) 
        result = self.validator.call(match)
        verb = "pass"
      else
        result = self.validator === match
        verb = "match"
      end

      unless result
        { valid: false, error: "#{self.identifier.inspect} must #{verb} #{self.validator}, but was #{match.inspect}"}
      else
        { valid: true }
      end
    end

    def match(row)
      element = row.find { |n,_| self.matcher === n } 
      element && element.last
    end

    def process(row)
      match = self.match(row)
      self.converter ? self.converter.call(match) : match
    rescue
      nil
    end

    def ivar_symbol
      :"@#{self.identifier}"
    end
  end
end
