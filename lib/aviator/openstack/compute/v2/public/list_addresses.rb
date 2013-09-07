module Aviator

  define_request :list_addresses do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :public

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/List_Addresses-d1e3014.html'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/List_Addresses_by_Network-d1e3118.html'


    param :id,        required: true
    param :networkID, required: false


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

      url = "#{ service_spec[:endpoints][0][:publicURL] }/servers/#{ params[:id] }/ips"
      url += "/#{ params[:networkID] }" if params[:networkID]

      url
    end

  end

end
