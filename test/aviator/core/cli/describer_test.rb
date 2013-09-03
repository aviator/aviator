require 'test_helper'

class Aviator::Test
  
  describe 'aviator/core/cli/describer' do
    
    def get_provider_names
      Pathname.new(__FILE__)
        .join('..', '..', '..', '..', '..', 'lib', 'aviator')
        .children
        .select{|c| c.directory? && c.basename.to_s != 'core' }
        .map{|c| c.basename.to_s }
    end
    
    
    def get_random_entry(array)
      array[rand(array.length)]
    end


    def get_request_classes(provider_name, service_name)
      service = Aviator::Service.new(provider: provider_name, service: service_name)
      service.request_classes
    end
    
    
    def get_service_names(provider_name)
      Pathname.new(__FILE__)
        .join('..', '..', '..', '..', '..', 'lib', 'aviator', provider_name)
        .children
        .select{|c| c.directory? }
        .map{|c| c.basename.to_s }
    end
    

    describe '::describe_aviator' do
      
      it 'describes the aviator gem' do
        provider_names = get_provider_names
        
        display = "Available providers:\n"
      
        provider_names.each do |provider_name|
          display << "  #{ provider_name }\n"
        end

        Aviator::Describer.describe_aviator.must_equal display
      end
      
    end # describe '::describe_aviator'
    
    
    describe '::describe_provider' do
      
      it 'describes the given provider' do
        provider_name = get_random_entry(get_provider_names)
        service_names = get_service_names(provider_name)
        
        display = "Available services for #{ provider_name }:\n"
      
        service_names.each do |service_name|
          display << "  #{ service_name }\n"
        end

        Aviator::Describer.describe_provider('openstack').must_equal display
      end
      
    end # describe '::describe_provider'
    
    
    describe '::describe_service' do
      
      it 'describes a given service for a given provider' do
        provider_name   = get_random_entry(get_provider_names)
        service_name    = get_random_entry(get_service_names(provider_name))
        request_classes = get_request_classes(provider_name, service_name)
                
        display = "Available requests for #{ provider_name } #{ service_name }_service:\n"

        request_classes.each do |klass|
          display << "  #{ klass.api_version } #{ klass.endpoint_type } #{ klass.name.split('::').last.underscore }\n"
        end
      
        Aviator::Describer.describe_service(provider_name, service_name).must_equal display
      end
      
    end # describe '::describe_service'    
    
    
    describe '::describe_request' do
      
      it 'describes a given request' do
        provider_name = get_random_entry(get_provider_names)
        service_name  = get_random_entry(get_service_names(provider_name))
        request_class = get_random_entry(get_request_classes(provider_name, service_name))
        request_name  = request_class.name.split('::').last.underscore
        
        display  = "Request: #{ request_name }\n\n"
        
        display << "Parameters:\n"

        params = request_class.optional_params.map{|p| [p, :required]} + 
                 request_class.required_params.map{|p| [p, :optional]}
        
        params.sort{|a,b| a[0].to_s <=> b[0].to_s }.each do |param|
          display << "  (#{ param[1].to_s }) #{ param[0] }\n"
        end
        
        display << "\nSample Code:\n"

        display << "  session.#{ service_name }_service.request(:#{ request_name }, endpoint_type: '#{ request_class.endpoint_type }')"
        if params
          display << " do |params|\n"
          params.each do |pair|
            display << "     params['#{ pair[0] }'] = value\n"
          end
          display << "  end\n"
        end
        
        if request_class.links
          display << "\nLinks:\n"
          
          request_class.links.each do |link|
            display << "  #{ link[:rel] }:\n"
            display << "    #{ link[:href] }\n"
          end
        end
              
        Aviator::Describer.describe_request(
          provider_name, service_name, request_class.api_version.to_s, 
          request_class.endpoint_type.to_s, request_name
        ).must_equal display
      end
      
    end # describe '::describe_request'    
    
    
  end # describe 'aviator/core/cli/describe'
  
end # class Aviator::Test
