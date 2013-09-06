module Aviator

  define_request :update_server do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :public

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/ServerUpdate.html'

    param :accessIPv4, required: false
    param :accessIPv6, required: false
    param :id,         required: true
    param :name,       required: false


    def body
      p = {
        server: { }
      }

      [:name, :accessIPv4, :accessIPv6].each do |key|
        p[:server][key] = params[key] if params[key]
      end

      p
    end


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:access][:token][:id]
      end

      h
    end


    def http_method
      :put
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service.to_s }
      "#{ service_spec[:endpoints][0][:publicURL] }/servers/#{ params[:id] }"
    end

  end

end
