module Aviator

  define_request :base do

    meta :provider,      :openstack
    meta :service,       :common
    meta :api_version,   :v0
    meta :endpoint_type, :public

    def headers
      {}.tap do |h|
        if self.anonymous?
          # do nothing

        elsif session_data.has_key? :service_token
          # service_token is the token that one would bootstrap OpenStack
          # with during the installation process. This token can be used
          # directly and does not require authentication beforehand.
          h['X-Auth-Token'] = session_data[:service_token]

        elsif keystone_v2_style_session_data?
          h['X-Auth-Token'] = session_data[:body][:access][:token][:id]

        elsif keystone_v3_style_session_data?
          h['X-Auth-Token'] = session_data[:headers]['x-subject-token']

        else
          raise "Unknown session data format!"

        end
      end
    end


    private

    def base_url
      if session_data[:base_url]
        session_data[:base_url]

      elsif keystone_v2_style_session_data? && keystone_v2_style_service_info?
        extract_base_url_from_keystone_v2_session_data

      elsif keystone_v3_style_session_data? && keystone_v3_style_service_info?
        extract_base_url_from_keystone_v3_session_data

      elsif session_data[:auth_service] && session_data[:auth_service][:host_uri] && session_data[:auth_service][:api_version]
        version = session_data[:auth_service][:api_version].to_s == "v2" ? "v2.0" : session_data[:auth_service][:api_version]
        "#{ session_data[:auth_service][:host_uri] }/#{ version }"

      elsif session_data[:auth_service] && session_data[:auth_service][:host_uri]
        session_data[:auth_service][:host_uri]

      else
        raise Aviator::Service::MissingServiceEndpointError.new(service.to_s, self.class)
      end
    end


    def build_service_type_string
      api_versions_without_a_suffix = [
        [:compute,  :v2],
        [:ec2,      :v1],
        [:identity, :v2],
        [:image,    :v1],
        [:metering, :v1],
        [:s3,       :v1],
        [:volume,   :v1]
      ]

      if api_versions_without_a_suffix.include? [service, api_version]
        service.to_s
      else
        "#{ service }#{ api_version }"
      end
    end


    def extract_base_url_from_keystone_v2_session_data
      service_info = session_data[:body][:access][:serviceCatalog].find{ |s| s[:type] == build_service_type_string }
      service_info[:endpoints][0]["#{ endpoint_type }URL".to_sym]
    end


    def extract_base_url_from_keystone_v3_session_data
      service_info = session_data[:body][:token][:catalog].select{ |s| s[:type] == build_service_type_string }
      endpoints = service_info.find{ |s| s.keys.include? "endpoints" }['endpoints']

      endpoints.find{ |s| s['interface'] == endpoint_type.to_s }['url']
    end


    def keystone_v2_style_service_info?
      not session_data[:body][:access][:serviceCatalog].find{ |s| s[:type] == build_service_type_string }.nil?
    end


    def keystone_v2_style_session_data?
      session_data.has_key?(:body) && session_data[:body].has_key?(:access)
    end


    def keystone_v3_style_service_info?
        not session_data[:body][:token][:catalog].find{ |s| s[:type] == build_service_type_string }.nil?
    end


    def keystone_v3_style_session_data?
      session_data.has_key?(:headers) && session_data[:headers].has_key?("x-subject-token")
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
