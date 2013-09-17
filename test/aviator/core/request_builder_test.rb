require 'test_helper'

class Aviator::Test

  describe 'aviator/core/request_builder' do
    
    describe '::define_request' do
      
      it 'places the request class in the right namespace' do
        provider = :dopenstack
        service  = :supermega
        api_ver  = :v999
        ep_type  = :uber
        _name_   = :sample

        Aviator.define_request _name_ do 
          meta :provider,      provider
          meta :service,       service
          meta :api_version,   api_ver
          meta :endpoint_type, ep_type
        end
        
        [provider, service, api_ver, ep_type, _name_].inject(Aviator) do |namespace, sym|
          const_name = sym.to_s.camelize
          
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
        
        Aviator.define_request _name_ do 
          meta :provider,      provider
          meta :service,       service
          meta :api_version,   api_ver
          meta :endpoint_type, ep_type
        end
        
        [provider, service, api_ver, ep_type, _name_].inject(Aviator) do |namespace, sym|
          const_name = sym.to_s.camelize
          
          namespace.const_defined?(const_name, false).must_equal true, 
            "Expected #{ const_name } to be defined in #{ namespace }"
          
          namespace.const_get(const_name, false)
        end   
      end


      it 'understands request inheritance' do
        base = {
          provider: :base_provider,
          service:  :base_service,
          api_ver:  :base_api_ver,
          ep_type:  :base_ep_type,
          name:     :base_name
        }

        Aviator.define_request base[:name] do
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

        Aviator.define_request :child_request, base_request do; end

        child_req_hierarchy = [
          base[:provider],
          base[:service],
          base[:api_ver],
          base[:ep_type],
          :child_request
        ]

        child_request = child_req_hierarchy.inject(Aviator) do |namespace, sym|
          namespace.const_get(sym.to_s.camelize, false)
        end

        child_request.wont_be_nil
        child_request.provider.must_equal      base[:provider]
        child_request.service.must_equal       base[:service]
        child_request.api_version.must_equal   base[:api_ver]
        child_request.endpoint_type.must_equal base[:ep_type]
      end


      it 'raises a BaseRequestNotFoundError if base request does not exist' do
        non_existent_base = [:non, :existent, :base]

        the_method = lambda do
          Aviator.define_request :child, non_existent_base do; end
        end

        the_method.must_raise Aviator::BaseRequestNotFoundError

        error = the_method.call rescue $!

        error.message.wont_be_nil
        error.base_request_hierarchy.wont_be_nil
        error.base_request_hierarchy.must_equal non_existent_base
      end

    end
    
  end
  
end