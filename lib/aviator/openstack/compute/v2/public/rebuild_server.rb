module Aviator

  define_request :rebuild_server do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :public

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Rebuild_Server-d1e3538.html'

    param :accessIPv4,  required: false
    param :accessIPv6,  required: false
    param :adminPass,   required: true
    param :id,          required: true
    param :imageRef,    required: true
    param :metadata,    required: false
    param :name,        required: true
    param :personality, required: false


    def body
      p = {
        rebuild: {
          adminPass: params[:adminPass],
          imageRef:  params[:imageRef],
          name:      params[:name]
        }
      }
      
      [:accessIPv4, :accessIPv6, :metadata, :personality].each do |key|
        p[:rebuild][key] = params[key] if params[key]
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
      "#{ service_spec[:endpoints][0][:publicURL] }/servers/#{ params[:id] }/action"
    end

  end

end
