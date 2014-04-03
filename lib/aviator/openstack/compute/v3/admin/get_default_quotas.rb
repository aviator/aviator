module Aviator

  define_request :get_default_quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service,      :compute
    meta :api_version,  :v3

    link 'documentation',
      'http://api.openstack.org/api-ref-compute-v3.html#v3quotasets'

    param :tenant_id, required: true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'computev3' }
      v3_url = service_spec[:endpoints][0][:adminURL]
      "#{ v3_url }/os-quota-sets/#{ params[:tenant_id] }/defaults"
    end

  end

end
