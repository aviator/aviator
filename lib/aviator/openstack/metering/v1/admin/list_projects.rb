module Aviator

  define_request :list_projects do

    meta :provider,      :openstack
    meta :service,       :metering
    meta :api_version,   :v1
    meta :endpoint_type, :admin

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
      uri = URI(service_spec[:endpoints][0][:adminURL])
      "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v1/projects"
    end

  end

end
