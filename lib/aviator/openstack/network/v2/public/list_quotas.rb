module Aviator

  define_request :list_quotas, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :network

    link 'documentation',
         'http://developer.openstack.org/api-ref-networking-v2.html#quotas-ext'

    param :tenant_id,  required: false

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      url = "#{ base_url }v2.0/quotas/#{ params['tenant_id'] }"

      url
    end

  end

end

