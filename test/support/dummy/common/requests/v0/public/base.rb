module Aviator

  define_request :base do

    meta :provider,      :dummy
    meta :service,       :common
    meta :api_version,   :v0
    meta :endpoint_type, :public

    private

    def base_url
      "#{session_data[:auth_service][:host_uri]}/v1"
    end

  end

end
