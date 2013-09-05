module Aviator
  
  define_request :list_flavors do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :public

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/List_Flavors-d1e4188.html'

    param :details, required: false
    param :minDisk, required: false
    param :minRam,  required: false
    param :marker,  required: false
    param :limit,   required: false


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:access][:token][:id]
      end

      h
    end


    def http_method
      :get
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service.to_s }

      str  = "#{ service_spec[:endpoints][0][:publicURL] }/flavors"
      str += "/detail" if params[:details]
      
      filters = []
      
      (optional_params + required_params - [:details]).each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end
      
      str += "?#{ filters.join('&') }" unless filters.empty?
      
      str
    end

  end

end
