module Constructable
  class Constructor
    def initialize(klass)
      @attributes = []
      @klass = klass
      constructor = self
      @klass.define_singleton_method(:new) do |*args, &block|
        obj = self.allocate
        constructor_hash = Hash === args.last ? args.pop : {}
        constructor.construct(constructor_hash, obj)
        obj.send :initialize, *args, &block
        obj
      end
    end


    def define_attributes(attributes)
      attributes = generate_attributes(attributes)
      @attributes.concat attributes

      attributes = @attributes
      attributes.each do |attribute|
        @klass.class_eval do

          attr_reader attribute.name if attribute.readable

          define_method(:"#{attribute.name}=") do |value|
            instance_variable_set attribute.ivar_symbol, attribute.process({ attribute.name => value})
          end if attribute.writable

          define_method(attribute.group) do
            attributes.group_by(&:group)[attribute.group].inject({}) do |hash, attribute|
              hash[attribute.name] = attribute.value
              hash
            end
          end if attribute.group && !method_defined?(attribute.group)
        end
      end
    end

    def construct(constructor_hash, obj)
      constructor_hash ||= {}
      @attributes.each do |attributes|
        obj.instance_variable_set(attributes.ivar_symbol, attributes.process(constructor_hash))
      end
    end

    def generate_attributes(attributes)
      attributes.map do |dynamic_args|
        if Hash === dynamic_args
          dynamic_args.map do |name, attributes|
            attributes.map do |attribute|
              Attribute.new(*attribute).tap { |a| a.group = dynamic_args.keys.first }
            end
          end
        else
          Attribute.new(*dynamic_args)
        end
      end.flatten
    end
  end
end
