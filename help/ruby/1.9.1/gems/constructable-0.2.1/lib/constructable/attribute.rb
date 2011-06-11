module Constructable
  class Attribute
    ATTRIBUTES = [:group, :writable, :readable, :accessible, :required, :validate, :default, :validate_type, :converter]
    attr_accessor *ATTRIBUTES, :name
    attr_reader :value

    REQUIRED_REQUIREMENT = {
      name: :required,
      message: proc {":#{self.name} is a required attribute"},
      check: ->(hash) { hash.has_key?(self.name) }
    }

    REQUIREMENTS = [
      {
        name: :validate,
        message: proc {":#{self.name} did not pass validation"},
        check: ->(hash) { self.validate.call(hash[self.name])}
      },
      {
        name: :validate_type,
        message: proc {":#{self.name} needs to be of type #{self.validate_type}"},
        check: ->(hash) { hash[self.name].is_a? self.validate_type }
      }
    ]

    def initialize(name, options = {})
      @name = name
      ATTRIBUTES.each do |attribute|
        self.send(:"#{attribute}=", options[attribute])
      end
    end

    def defined?
      @defined
    end

    def accessible=(boolean)
      if boolean
        self.readable = true
        self.writable = true
      end
    end

    def ivar_symbol
      ('@' + self.name.to_s).to_sym
    end

    def check_for_requirement(requirement, constructor_hash)
      if self.send requirement[:name]
        unless self.instance_exec(constructor_hash,&requirement[:check])
          raise AttributeError, instance_eval(&requirement[:message])
        end
      end
    end
    private :check_for_requirement

    def process(constructor_hash)
      if constructor_hash.has_key?(self.name)
        REQUIREMENTS.each do |requirement|
          check_for_requirement(requirement, constructor_hash)
        end
        value = constructor_hash[self.name]
        @defined = true
        self.converter ? converter.(value) : value
      else
        check_for_requirement(REQUIRED_REQUIREMENT, constructor_hash)
        @defined = false
        self.default
      end.tap { |value| @value = value }
    end
  end
end
