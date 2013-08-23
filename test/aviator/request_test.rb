require 'test_helper'

class Aviator::Test::Request < Aviator::Test::Base

  describe 'Aviator::Request' do


    describe '#allow_anonymous?' do

      it 'is false by default' do
        obj = Aviator::Request.new

        obj.allow_anonymous?.must_equal false
      end

    end


    describe '::allows_anonymous' do

      it 'is a private class method' do
        private_method = lambda { Aviator::Request.allow_anonymous }
        private_method.must_raise NoMethodError

        error = private_method.call rescue $!

        error.message.wont_be_nil
      end

      it 'sets a Request instance to allow anonymous access' do
        klass = Class.new(Aviator::Request) do 
                  allow_anonymous
                end
                
        obj   = klass.new

        obj.allow_anonymous?.must_equal true
      end

    end
    
    
    describe '#http_method' do
      
      it 'is set to get by default' do
        obj = Aviator::Request.new

        obj.http_method.must_equal :get
      end
      
    end
    
    
    describe '::http_method' do

      it 'is a private class method' do
        private_method = lambda { Aviator::Request.http_method }
        private_method.must_raise NoMethodError

        error = private_method.call rescue $!

        error.message.wont_be_nil
        error.message.must_include "private method"
      end


      it 'sets the http method of its instances' do
        klass = Class.new(Aviator::Request) do 
                  http_method :post
                end
                
        obj = klass.new

        obj.http_method.must_equal :post
      end

    end


    describe '::requires_param' do

      it 'is a private class method' do
        private_method = lambda { Aviator::Request.requires_param }
        private_method.must_raise NoMethodError

        error = private_method.call rescue $!

        error.message.wont_be_nil
        error.message.must_include "private method"
      end
      
      
      it 'causes a Request instance to raise an error when initialized without the param' do
        klass = Class.new(Aviator::Request) do
                  requires_param :name
                end
                      
        initializer = lambda { klass.new({}) }
        initializer.must_raise ArgumentError
        
        error = initializer.call rescue $!
        
        error.message.wont_be_nil
      end


      it 'does not raise any error when the required param is provided on initialization' do
        klass = Class.new(Aviator::Request) do
                  requires_param :name
                end
                      
        obj = klass.new({ name: 'somename' })
      end

    end

  end

end
