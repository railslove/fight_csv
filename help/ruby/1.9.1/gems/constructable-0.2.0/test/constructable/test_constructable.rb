require 'helper'
describe 'integration' do
  describe 'Class' do
    describe 'constructable' do
      it 'should define attr_accessors' do
        klass = Class.new
        klass.constructable([:foo, accessible: true])
        assert_respond_to klass.new, :foo
        assert_respond_to klass.new, :foo=
      end

      it 'should assign values found in the constructer hash' do
        klass = Class.new
        klass.constructable([:foo, readable: true])
        instance = klass.new(foo: :bar)
        assert_equal :bar, instance.foo
      end

      it 'should work with inheritance' do
        klass = Class.new
        klass.constructable([:bar, readable: true])
        inherited_klass = Class.new(klass)
        instance = inherited_klass.new(bar: 1)
        assert_equal 1, instance.bar
      end

      it 'should be possible to make attributes required' do
        klass = Class.new
        klass.constructable([:bar, required: true])
        assert_raises AttributeError do
          klass.new
        end
      end

      describe 'should not break the initalize behaviour' do
        it 'works for methods with arguments + options provided' do
          klass = Class.new
          klass.constructable [:bar, accessible: true]
          klass.class_eval do
            def initialize
              self.bar = 20
            end
          end
          instance = klass.new(bar: 5)
          assert_equal 20, instance.bar
        end

        it 'works for methods with only arguments provided' do
          klass = Class.new
          klass.constructable [:bar, accessible: true]
          klass.class_eval do
            def initialize(bar)
              self.bar = bar
            end
          end

          instance = klass.new(1)
          assert_equal 1, instance.bar
        end
      end

      it 'should return nil' do
        klass = Class.new
        assert_equal nil, klass.constructable(:bar)
      end
    end
  end
end
