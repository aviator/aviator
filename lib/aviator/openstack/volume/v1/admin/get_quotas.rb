module Aviator

  define_request :get_quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service,      :volume
    meta :api_version,  :v1

    link 'documentation',
      'http://docs.openstack.org/trunk/openstack-ops/content/projects_users.html'

    param :tenant_id, required: true
    param :usage,     required: false

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      str = "#{ base_url }/os-quota-sets/#{ params[:tenant_id] }"
      str += "?usage=True" if params[:usage]

      str
    end

  end

end
