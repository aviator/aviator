require 'test_helper'

class Aviator::Test

  describe 'aviator/core/request_builder' do

    def builder
      Aviator
    end


    describe '::define_request' do

      it 'places the request class in the right namespace' do
        provider = :dopenstack
        service  = :supermega
        api_ver  = :v999
        ep_type  = :uber
        _name_   = :sample

        builder.define_request _name_ do
          meta :provider,      provider
          meta :service,       service
          meta :api_version,   api_ver
          meta :endpoint_type, ep_type
        end

        [provider, service, :requests, api_ver, ep_type, _name_].inject(builder) do |namespace, sym|
          const_name = Aviator::StrUtil.camelize(sym.to_s)

          namespace.const_defined?(const_name, false).must_equal true

          namespace.const_get(const_name, false)
        end
      end


      it 'does not get confused when a similar name is defined up in the namespace hierarchy' do
        provider = :aws
        service  = :amazing
        api_ver  = :fixnum        # This is on purpose and is critical to this test.
        ep_type  = :awesome
        _name_   = :this_request

        builder.define_request _name_ do
          meta :provider,      provider
          meta :service,       service
          meta :api_version,   api_ver
          meta :endpoint_type, ep_type
        end

        [provider, service, :requests, api_ver, ep_type, _name_].inject(builder) do |namespace, sym|
          const_name = Aviator::StrUtil.camelize(sym.to_s)

          namespace.const_defined?(const_name, false).must_equal true,
            "Expected #{ const_name } to be defined in #{ namespace }"

          namespace.const_get(const_name, false)
        end
      end


      it 'understands request inheritance' do
        base = {
          :provider => :another_provider,
          :service  => :base_service,
          :api_ver  => :base_api_ver,
          :ep_type  => :base_ep_type,
          :name     => :base_name
        }

        builder.define_request base[:name] do
          meta :provider,      base[:provider]
          meta :service,       base[:service]
          meta :api_version,   base[:api_ver]
          meta :endpoint_type, base[:ep_type]
        end

        base_request = [
          base[:provider],
          base[:service],
          base[:api_ver],
          base[:ep_type],
          base[:name]
        ]

        builder.define_request :child_request, :inherit => base_request do; end

        child_req_hierarchy = [
          base[:provider],
          base[:service],
          :requests,
          base[:api_ver],
          base[:ep_type],
          :child_request
        ]

        child_request = child_req_hierarchy.inject(builder) do |namespace, sym|
          namespace.const_get(Aviator::StrUtil.camelize(sym.to_s), false)
        end

        child_request.wont_be_nil
        child_request.provider.must_equal      base[:provider]
        child_request.service.must_equal       base[:service]
        child_request.api_version.must_equal   base[:api_ver]
        child_request.endpoint_type.must_equal base[:ep_type]
      end


      it 'raises a BaseRequestNotFoundError if base request does not exist' do
        non_existent_base = [:none, :existent, :base]

        the_method = lambda do
          builder.define_request :child, :inherit => non_existent_base do; end
        end

        the_method.must_raise Aviator::BaseRequestNotFoundError

        error = the_method.call rescue $!

        error.message.wont_be_nil
        error.base_request_hierarchy.wont_be_nil
        error.base_request_hierarchy.must_equal non_existent_base
      end


      it 'raises a RequestAlreadyDefinedError if the request is already defined' do
        request = {
          :provider => :existing_provider,
          :service  => :base_service,
          :api_ver  => :base_api_ver,
          :ep_type  => :base_ep_type,
          :name     => :base_name
        }

        builder.define_request request[:name] do
          meta :provider,      request[:provider]
          meta :service,       request[:service]
          meta :api_version,   request[:api_ver]
          meta :endpoint_type, request[:ep_type]
        end

        the_method = lambda do
          builder.define_request request[:name] do
            meta :provider,      request[:provider]
            meta :service,       request[:service]
            meta :api_version,   request[:api_ver]
            meta :endpoint_type, request[:ep_type]
          end
        end

        the_method.must_raise Aviator::RequestAlreadyDefinedError

        error = the_method.call rescue $!

        error.message.wont_be_nil
        error.request_name.must_equal Aviator::StrUtil.camelize(request[:name].to_s)
      end


      it 'automatically attempts to load the base class if it\'s not yet loaded' do
        base_arr  = [:openstack, :identity, :v2, :public, :root]
        child_arr = base_arr.first(base_arr.length - 1) + [:child]

        builder.define_request child_arr.last, :inherit => base_arr do; end

        base_klass = base_arr.insert(2, :requests).inject(builder) do |namespace, sym|
          namespace.const_get(Aviator::StrUtil.camelize(sym.to_s), false)
        end

        child_klass = child_arr.insert(2, :requests).inject(builder) do |namespace, sym|
          namespace.const_get(Aviator::StrUtil.camelize(sym.to_s), false)
        end

        base_klass.wont_be_nil
        child_klass.wont_be_nil
      end

    end

  end

end
