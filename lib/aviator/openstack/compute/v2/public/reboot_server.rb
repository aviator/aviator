module Aviator

  define_request :reboot_server do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :public

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Reboot_Server-d1e3371.html'

    param :id,   required: true
    param :type, required: false


    def body
      p = {
        reboot: {
          type: params[:type] || 'SOFT'
        }
      }

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
