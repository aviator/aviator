module Aviator

  define_request :get_tenant_by_id, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :identity

    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/GET_listUsers_v2.0_users_.html'


    param :id, required: true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      "#{ service_spec[:endpoints][0][:adminURL] }/tenants/#{ params[:id] }"
    end

  end

end
