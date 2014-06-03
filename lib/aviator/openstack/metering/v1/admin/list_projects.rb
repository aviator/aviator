module Aviator

  define_request :list_projects, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service,       :metering
    meta :api_version,   :v1
    meta :endpoint_type, :admin


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      uri = URI(base_url)
      "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v1/projects"
    end

  end

end
