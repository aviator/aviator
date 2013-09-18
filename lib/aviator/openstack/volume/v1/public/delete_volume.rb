module Aviator

  define_request :delete_volume do
    meta :provider,      :openstack
    meta :service,       :volume
    meta :api_version,   :v1
    meta :endpoint_type, :public

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/Delete_Volume.html'

    param :id, required: true

    def headers
      {}.tap do |h|
        h['X-Auth-Token'] = session_data[:access][:token][:id] unless self.anonymous?
      end
    end

    def http_method
      :delete
    end

    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service.to_s }

      "#{ service_spec[:endpoints][0][:publicURL] }/volumes/#{ params[:id] }"
    end
  end

end
