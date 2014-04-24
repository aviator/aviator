module Aviator

  define_request :get_default_quotas, inherit: [:openstack, :common, :v3, :admin, :base] do

    meta :service,      :compute

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

      service_spec = session_data[:catalog].find{|s| s[:type] == 'computev3' }
      v3_url = service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url]
      "#{ v3_url }/os-quota-sets/#{ params[:tenant_id] }/defaults"
    end

  end

end
