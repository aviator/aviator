module Aviator

  define_request :get_server do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :public

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Get_Server_Details-d1e2623.html'

    param :id, required: true

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

      "#{ service_spec[:endpoints][0][:publicURL] }/servers/#{ params[:id] }"
    end

  end

end
