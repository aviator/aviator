module Aviator

  define_request :create_server do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :public

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/CreateServers.html'

    param :accessIPv4,  required: false
    param :accessIPv6,  required: false
    param :adminPass,   required: false
    param :imageRef,    required: true
    param :flavorRef,   required: true
    param :metadata,    required: false
    param :name,        required: true
    param :networks,    required: false
    param :personality, required: false


    def body
      p = {
        server: {
          flavorRef: params[:flavorRef],
          imageRef:  params[:imageRef],
          name:      params[:name]
        }
      }

      [:adminPass, :metadata, :personality, :networks, :accessIPv4, :accessIPv6].each do |key|
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
      :post
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service.to_s }
      "#{ service_spec[:endpoints][0][:publicURL] }/servers"
    end

  end

end
