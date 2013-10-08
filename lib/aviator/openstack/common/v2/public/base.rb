module Aviator

  define_request :base do

    meta :provider,      :openstack
    meta :service,       :common
    meta :api_version,   :v2
    meta :endpoint_type, :public

    def headers
      {}.tap do |h|
        h['X-Auth-Token'] = session_data[:access][:token][:id] unless self.anonymous?
      end
    end


    private


    def base_url
      if session_data[:base_url]
        session_data[:base_url]
      elsif service_spec = session_data[:access][:serviceCatalog].find { |s| s[:type] == service.to_s }
        service_spec[:endpoints][0]["#{ endpoint_type }URL".to_sym]
      elsif session_data[:auth_service] && session_data[:auth_service][:host_uri] && session_data[:auth_service][:api_version]
        "#{ session_data[:auth_service][:host_uri] }/v2.0"
      elsif session_data[:auth_service] && session_data[:auth_service][:host_uri]
        session_data[:auth_service][:host_uri]
      else
        raise Aviator::Service::MissingServiceEndpointError.new(service.to_s, self.class)
      end
    end


    def params_to_querystring(param_names)
      filters = []

      param_names.each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      filters.empty? ? "" : "?#{ filters.join('&') }"
    end

  end

end
