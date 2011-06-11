require 'helper'
describe 'Constructor' do
  before do
    @klass = Class.new
  end

  describe 'define_attributes' do
    it 'defines public setters validating like in the constructor' do
      @klass.constructable [:integer, validate_type: Integer, writable: true]
      instance = @klass.new
      assert_raises AttributeError do
        instance.integer = 6.6
      end
    end
  end

  describe 'Attribute#group' do
    it 'returns attributes included in the group along with their values' do
      @klass.constructable [:foo, group: :foobar], [:bar, group: :foobar]
      instance = @klass.new(foo: 1, bar: 2)
      assert_equal({foo: 1, bar: 2}, instance.foobar)
    end

    it 'ONLY returns attributes included in that group' do
      @klass.constructable [:foo, group: :foobar], [:bar]
      instance = @klass.new(foo: 1, bar: 2)
      assert_equal({foo: 1}, instance.foobar)
    end

    it 'has a nice syntax' do
      @klass.constructable foobar: [:foo, :bar]
      instance = @klass.new(foo: 1, bar: 2)
      assert_equal({foo: 1, bar: 2}, instance.foobar)
    end

    it 'ONLY returns attributes acutally provided' do
      @klass.constructable foobar: [:foo, :bar]
      instance = @klass.new(foo: 1)
      assert_equal false, instance.foobar.has_key?(:bar)
    end
  end

  describe 'permission' do
    it 'should allow writable attributes' do
      @klass.constructable [:writable_attribute, writable: true]
      instance = @klass.new
      instance.writable_attribute = "hello"
      assert_equal "hello", instance.instance_variable_get(:@writable_attribute)
    end

    it 'should allow readable attributes' do
      @klass.constructable [:readable_attribute, readable: true]
      instance = @klass.new
      instance.instance_variable_set(:@readable_attribute, "hello")
      assert_equal "hello", instance.readable_attribute
    end

    it 'should allow accessible attributes' do
      @klass.constructable [:accessible_attribute, accessible: true]
      instance = @klass.new
      instance.accessible_attribute = 'hello'
      assert_equal 'hello', instance.accessible_attribute
    end
  end
end
