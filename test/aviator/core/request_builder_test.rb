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

    end
    
  end
  
end