module FightCSV
  class Field

    REQUIREMENTS = {
      required: {
        message: proc { |match| "#{self.identifier.inspect} is a required field" },
        test: proc { |match, boolean| !boolean },
      },
      validator: {
        message: proc { |match| "Value of #{identifier.inspect} must #{ self.validator.respond_to?(:call) ? "pass" : "match" } #{self.validator}, but was #{match.last}" },
        test: proc { |match, validator|  validator.respond_to?(:call) ? validator.call(match.last) : self.validator === match.last }
      }
    }

    constructable [:converter, validate_type: Proc, accessible: true],
                  [:identifier, validate_type: Symbol, accessible: true, required: true],
                  [:required, default: true, accessible: true, accessible: true],
                  [:validator, accessible: true]

    attr_accessor :matcher

    def initialize(matcher)
      @matcher = matcher
    end

    def validate(row)
      match = self.match(row)
      validation_hash = {errors: [], valid: true}
      if match
        process_requirement(:validator, match, validation_hash) if validator
      else
        process_requirement(:required, match, validation_hash)
      end
      return validation_hash
    end

    def process_requirement(requirement_symbol, match, validation_hash)
      requirement = REQUIREMENTS[requirement_symbol]
      result = instance_exec(match, attributes[requirement_symbol], &requirement[:test])
      validation_hash[:valid] &&= result
      unless result
        validation_hash[:errors] << instance_exec(match, &requirement[:message])
      end
    end

    def match(row)
      row.find { |n,_| self.matcher === n }
    end

    def process(row)
      if match = self.match(row)
        self.converter ? self.converter.call(match.last) : match.last
      else
        nil
      end
    end
  end
end
