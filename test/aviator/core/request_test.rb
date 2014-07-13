require 'test_helper'

class Aviator::Test

  describe 'aviator/core/request' do

    describe '::new' do

      it 'raises an error when a required param is not provided' do
        klass = Class.new(Aviator::Request) do
                  param :someparamname, :required => true
                end

        the_method = lambda { klass.new }
        the_method.must_raise ArgumentError

        error = the_method.call rescue $!

        error.message.wont_be_nil
        error.message.must_include "someparamname"
      end


      it 'does not raise any error when the required param is provided' do
        klass = Class.new(Aviator::Request) do
                  param :someparamname, :required => true
                end

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
                  meta :anonymous, true
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
                  meta :anonymous, true
                end

        klass.new.anonymous?.must_equal true
      end

    end


    describe '::api_version' do

      it 'returns the api version' do
        klass = Class.new(Aviator::Request) do
          meta :api_version, :v2
        end

        klass.api_version.must_equal :v2
      end

    end


    describe '#api_version' do

      it 'returns the api version' do
        klass = Class.new(Aviator::Request) do
          meta :api_version, :v2
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
          meta :endpoint_type, :public
        end

        klass.endpoint_type.must_equal :public
      end

    end


    describe '#endpoint_type' do

      it 'returns the endpoint type' do
        klass = Class.new(Aviator::Request) do
          meta :endpoint_type, :whatever
        end

        klass.new.endpoint_type.must_equal :whatever
      end

    end


    describe '#http_method' do

      it 'returns the http method if it is defined' do
        klass = Class.new(Aviator::Request) do
                  def http_method; :post; end
                end

        klass.new.http_method.must_equal :post
      end

    end


    describe '::link' do

      it 'adds a link to Request::links' do
        rel  = 'documentation'
        href = 'http://x.y.z'

        klass = Class.new(Aviator::Request) do
                  link rel, href
                end

        expected = [
          { :rel => rel, :href => href }
        ]

        klass.links.must_equal expected
        klass.new.links.must_equal expected
      end

    end


    describe '::param' do

      it 'is a private class method' do
        private_method = lambda { Aviator::Request.param }
        private_method.must_raise NoMethodError

        error = private_method.call rescue $!

        error.message.wont_be_nil
        error.message.must_include "private method"
      end


      it 'accepts an alias for a given parameter' do
        klass = Class.new(Aviator::Request) do
                  param :the_param, :required => true, :alias => :the_alias
                end

        param_val = 999

        req = klass.new do |params|
                params.the_param = param_val
              end

        req.params.the_param.must_equal param_val
        req.params.the_alias.must_equal param_val
      end


      it 'makes the param alias assignable' do
        klass = Class.new(Aviator::Request) do
                  param :the_param, :required => true, :alias => :the_alias
                end

        param_val = 999

        req = klass.new do |params|
                params.the_alias = param_val
              end

        req.params.the_param.must_equal param_val
        req.params.the_alias.must_equal param_val
      end


      it 'allows aliases to be accessible as symbols' do
        klass = Class.new(Aviator::Request) do
                  param :the_param, :required => true, :alias => :the_alias
                end

        param_val = 999

        req = klass.new do |params|
                params[:the_alias] = param_val
              end

        req.params[:the_param].must_equal param_val
        req.params[:the_alias].must_equal param_val
      end


      it 'allows aliases to be accessible as strings' do
        klass = Class.new(Aviator::Request) do
                  param :the_param, :required => true, :alias => :the_alias
                end

        param_val = 999

        req = klass.new do |params|
                params['the_alias'] = param_val
              end

        req.params['the_param'].must_equal param_val
        req.params['the_alias'].must_equal param_val
      end

    end


    describe '::optional_params' do

      it 'returns an array' do
        klass = Class.new(Aviator::Request) do
                  param :whatever, :required => false
                end

        klass.optional_params.must_equal [:whatever]
      end

    end


    describe '#optional_params' do

      it 'returns an array' do
        klass = Class.new(Aviator::Request) do
                  param :whatever, :required => false
                end

        klass.new.optional_params.must_equal [:whatever]
      end

    end


    describe '::required_params' do

      it 'returns an array' do
        klass = Class.new(Aviator::Request) do
                  param :whatever, :required => true
                end

        klass.required_params.must_equal [:whatever]
      end

    end


    describe '#required_params' do

      it 'returns an array' do
        klass = Class.new(Aviator::Request) do
                  param :whatever, :required => true
                end

        request = klass.new do |params|
                    params[:whatever] = 'something'
                  end


        request.required_params.must_equal [:whatever]
      end

    end


    describe '::url?' do

      it 'returns false if the url method is not defined' do
        klass = Class.new(Aviator::Request)

        klass.url?.must_equal false
      end


      it 'returns true if the url method is defined' do
        klass = Class.new(Aviator::Request) do
          def url; end
        end

        klass.url?.must_equal true
      end

    end


    describe '#url?' do

      it 'returns false if the url method is not defined' do
        klass = Class.new(Aviator::Request)

        klass.new.url?.must_equal false
      end


      it 'returns true if the url method is defined' do
        klass = Class.new(Aviator::Request) do
          def url; end
        end

        klass.new.url?.must_equal true
      end

    end


  end

end
