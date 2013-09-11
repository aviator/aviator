module Aviator

  define_request :root do

    meta :provider,      :openstack
    meta :service,       :volume
    meta :api_version,   :v1
    meta :endpoint_type, :public

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
      uri = URI(service_spec[:endpoints][0][:publicURL])
      "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v1/"
    end

  end

end
