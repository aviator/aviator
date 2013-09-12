module Aviator

  define_request :get_host_details do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
      'http://api.openstack.org/api-ref.html#ext-os-hosts'

    param :host_name, required: true


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
      service_spec = session_data[:access][:serviceCatalog].find { |s| s[:type] == service.to_s }

      "#{ service_spec[:endpoints][0][:adminURL] }/os-hosts/#{ params[:host_name] }"
    end

  end

end
