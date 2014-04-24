module Aviator

  define_request :revert_server_resize do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Revert_Resized_Server-d1e4024.html'

    param :id, required: true


    def body
      {
        revertResize: nil
      }
    end


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data.token
      end

      h
    end


    def http_method
      :post
    end


    def url
      service_spec = session_data[:catalog].find{|s| s[:type] == service.to_s }
      "#{ service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url] }/servers/#{ params[:id] }/action"
    end

  end

end
