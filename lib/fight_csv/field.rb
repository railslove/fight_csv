module FightCSV
  class Field
    constructable [:converter, validate_type: Proc, readable: true],
                  [:required, default: true, readable: true],
                  [:validator, readable: true]

    attr_accessor :matcher

    def initialize(matcher)
      @matcher = matcher
    end
  end
end
