module FightCSV
  class Field
    constructable :converter, validate_type: Proc, accessible: true
    constructable :identifier, validate_type: Symbol, accessible: true, required: true
    constructable :validator, accessible: true, default: ->{/.*/}

    attr_accessor :matcher

    def initialize(matcher, options = {})
      @matcher = matcher
    end

    def validate(row, header = nil)
      match = self.match(row, header).to_s
      if self.validator.respond_to?(:call) 
        result = self.validator.call(match)
        verb = "pass"
      else
        result = (self.validator === match)
        verb = "match"
      end

      unless result
        { valid: false, error: "#{self.identifier.inspect} must #{verb} #{self.validator}, but was #{match.inspect}"}
      else
        { valid: true }
      end
    end

    def match(row, header = nil)
      case self.matcher
      when Integer
        row[matcher-1]
      else
        raise ArgumentError, 'No header is provided, but a matcher other than an Integer requires one' unless header
        index = header.index  { |n| self.matcher === n }
        index ? row[index] : nil
      end
    end

    def process(row, header = nil)
      match = self.match(row, header).to_s
      self.converter ? self.converter.call(match) : match
    end

    def ivar_symbol
      :"@#{self.identifier}"
    end
  end
end
