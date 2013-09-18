module Aviator

  define_request :base do

    meta :provider,      :openstack
    meta :service,       :common
    meta :api_version,   :v2
    meta :endpoint_type, :public

    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:access][:token][:id]
      end

      h
    end


    private

    def url_for(endpoint_type)
      service_spec = session_data[:access][:serviceCatalog].find { |s| s[:type] == service.to_s }
      service_spec[:endpoints][0]["#{ endpoint_type }URL".to_sym]
    end

  end

end
