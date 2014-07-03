module Aviator

  define_request :simple_tenant_usage, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-v2-ext.html#ext-os-simple-tenant-usage'

    param :tenant_id, required: false
    param :start, required: false
    param :end, required: false
    param :detailed, required: false

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      url = "#{ base_url }/os-simple-tenant-usage"

      filters = []

      optional_params.each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      url += "?#{ filters.join('&') }" unless filters.empty?

      url
    end

  end

end

