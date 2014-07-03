module Aviator

  define_request :list_floatingips, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :network

    link 'documentation',
         'http://developer.openstack.org/api-ref-compute-v2-ext.html#ext-os-floating-ips'

    param :tenant_id,  required: false

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      url = "#{ base_url }v2.0/floatingips"

      filters = []

      optional_params.each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      url += "?#{ filters.join('&') }" unless filters.empty?

      url
    end

  end

end

