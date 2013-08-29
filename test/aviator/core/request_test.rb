require 'test_helper'

class Aviator::Test

  describe 'aviator/core/request' do

    describe '::new' do

      it 'raises an error when a required param is not provided' do
        klass = Class.new(Aviator::Request) do
                  required_param :someparamname
                end

        initializer = lambda { klass.new }
        initializer.must_raise ArgumentError

        error = initializer.call rescue $!

        error.message.wont_be_nil
        error.message.must_include "someparamname"
      end


      it 'does not raise any error when the required param is provided' do
        klass = Class.new(Aviator::Request) do
                  required_param :someparamname
                end

        # obj = klass.new({ someparamname: 'someparamvalue' })

        obj = klass.new do |params|
          params.someparamname = 'something'
        end
      end

    end


    describe '::anonymous?' do

      it 'is false by default' do
        klass = Class.new(Aviator::Request)

        klass.anonymous?.must_equal false
      end


      it 'returns true if specified as such' do
        klass = Class.new(Aviator::Request) do
                  anonymous
                end

        klass.anonymous?.must_equal true
      end

    end


    describe '#anonymous?' do

      it 'is false by default' do
        klass = Class.new(Aviator::Request)

        klass.new.anonymous?.must_equal false
      end


      it 'returns true if specified as such' do
        klass = Class.new(Aviator::Request) do
                  anonymous
                end

        klass.new.anonymous?.must_equal true
      end

    end


    describe '::api_version' do

      it 'returns the api version' do
        klass = Class.new(Aviator::Request) do
          api_version :v2
        end

        klass.api_version.must_equal :v2
      end

    end


    describe '#api_version' do

      it 'returns the api version' do
        klass = Class.new(Aviator::Request) do
          api_version :v2
        end

        klass.new.api_version.must_equal :v2
      end

    end


    describe '::body?' do

      it 'returns false if the body method is not defined' do
        klass = Class.new(Aviator::Request)

        klass.body?.must_equal false
      end


      it 'returns true if the body method is defined' do
        klass = Class.new(Aviator::Request) do
          def body; end
        end

        klass.body?.must_equal true
      end

    end


    describe '#body?' do

      it 'returns false if the body method is not defined' do
        klass = Class.new(Aviator::Request)

        klass.new.body?.must_equal false
      end


      it 'returns true if the body method is defined' do
        klass = Class.new(Aviator::Request) do
          def body; end
        end

        klass.new.body?.must_equal true
      end

    end


    describe '::endpoint_type' do

      it 'returns the endpoint type' do
        klass = Class.new(Aviator::Request) do
          endpoint_type :public
        end

        klass.endpoint_type.must_equal :public
      end

    end


    describe '#endpoint_type' do

      it 'returns the endpoint type' do
        klass = Class.new(Aviator::Request) do
          endpoint_type :public
        end

        klass.new.endpoint_type.must_equal :public
      end

    end


    describe '::http_method' do

      it 'returns the http method if it is defined' do
        klass = Class.new(Aviator::Request) do
                  http_method :post
                end

        klass.http_method.must_equal :post
      end

    end


    describe '#http_method' do

      it 'returns the http method if it is defined' do
        klass = Class.new(Aviator::Request) do
                  http_method :post
                end

        klass.new.http_method.must_equal :post
      end

    end


    describe '::link_to' do

      it 'adds a link to Request::links' do
        rel  = 'documentation'
        href = 'http://x.y.z'
        
        klass = Class.new(Aviator::Request) do
                  link_to rel, href
                end

        expected = [
          { rel: rel, href: href }
        ]
        
        klass.links.must_equal expected
        klass.new.links.must_equal expected
      end

    end
    

    describe '::optional_param' do

      it 'is a private class method' do
        private_method = lambda { Aviator::Request.optional_param }
        private_method.must_raise NoMethodError

        error = private_method.call rescue $!

        error.message.wont_be_nil
        error.message.must_include "private method"
      end

    end
    

    describe '::optional_params' do

      it 'returns an array' do
        klass = Class.new(Aviator::Request) do
                  optional_param :whatever
                end

        klass.optional_params.must_equal [:whatever]
      end

    end


    describe '#optional_params' do

      it 'returns an array' do
        klass = Class.new(Aviator::Request) do
                  optional_param :whatever
                end

        klass.new.optional_params.must_equal [:whatever]
      end

    end


    describe '::required_param' do

      it 'is a private class method' do
        private_method = lambda { Aviator::Request.required_param }
        private_method.must_raise NoMethodError

        error = private_method.call rescue $!

        error.message.wont_be_nil
        error.message.must_include "private method"
      end

    end


    describe '::required_params' do

      it 'returns an array' do
        klass = Class.new(Aviator::Request) do
                  required_param :whatever
                end

        klass.required_params.must_equal [:whatever]
      end

    end


    describe '#required_params' do

      it 'returns an array' do
        klass = Class.new(Aviator::Request) do
                  required_param :whatever
                end

        klass.required_params.must_equal [:whatever]
      end

    end
    

    describe '::url?' do

      it 'returns false if the path method is not defined' do
        klass = Class.new(Aviator::Request)

        klass.url?.must_equal false
      end


      it 'returns true if the path method is defined' do
        klass = Class.new(Aviator::Request) do
          def url; end
        end

        klass.url?.must_equal true
      end

    end


    describe '#path?' do

      it 'returns false if the path method is not defined' do
        klass = Class.new(Aviator::Request)

        klass.new.url?.must_equal false
      end


      it 'returns true if the path method is defined' do
        klass = Class.new(Aviator::Request) do
          def url; end
        end

        klass.new.url?.must_equal true
      end

    end


  end

end
