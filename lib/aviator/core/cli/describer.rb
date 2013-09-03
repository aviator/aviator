module Aviator
  
  module Describer

    def self.describe_aviator
      provider_names = Pathname.new(__FILE__)
                        .join('..', '..', '..')
                        .children
                        .select{|c| c.directory? && c.basename.to_s != 'core' }
                        .map{|c| c.basename.to_s }

      str = "Available providers:\n"

      provider_names.each do |provider_name|
        str << "  #{ provider_name }\n"
      end
      
      str
    end


    def self.describe_provider(provider_name)
      service_names = Pathname.new(__FILE__)
                        .join('..', '..', '..', provider_name)
                        .children
                        .select{|c| c.directory? }
                        .map{|c| c.basename.to_s }

      str = "Available services for #{ provider_name }:\n"

      service_names.each do |service_name|
        str << "  #{ service_name }\n"
      end
      
      str
    end


    def self.describe_request(provider_name, service_name, api_version, endpoint_type, request_name)
      service = Aviator::Service.new provider: provider_name, service: service_name
      request_class = "Aviator::#{ provider_name.camelize }::#{ service_name.camelize }::"\
                      "#{ api_version.camelize }::#{ endpoint_type.camelize }::#{ request_name.camelize }".constantize
                      
      str = "Request: #{ request_name }\n\n"
      
      str << "Parameters:\n"

      params = request_class.optional_params.map{|p| [p, :optional]} + 
               request_class.required_params.map{|p| [p, :required]}
      
      params.sort{|a,b| a[0].to_s <=> b[0].to_s }.each do |param|
        str << "  (#{ param[1].to_s }) #{ param[0] }\n"
      end
      
      str << "\nSample Code:\n"

      str << "  session.#{ service_name }_service.request(:#{ request_name }, endpoint_type: '#{ request_class.endpoint_type }')"
      if params
        str << " do |params|\n"
        params.each do |pair|
          str << "     params['#{ pair[0] }'] = value\n"
        end
        str << "  end\n"
      end
      
      if request_class.links
        str << "\nLinks:\n"
        
        request_class.links.each do |link|
          str << "  #{ link[:rel] }:\n"
          str << "    #{ link[:href] }\n"
        end
      end
      
      str
    end


    def self.describe_service(provider_name, service_name)
      service = Aviator::Service.new(provider: provider_name, service: service_name)
      klasses = service.request_classes
      
      str = "Available requests for #{ provider_name } #{ service_name }_service:\n"

      klasses.each do |klass|
        str << "  #{ klass.api_version } #{ klass.endpoint_type } #{ klass.name.split('::').last.underscore }\n"
      end
      
      str
    end


  end
  
end
