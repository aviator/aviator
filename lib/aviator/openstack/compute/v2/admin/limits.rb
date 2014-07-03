module Aviator

  define_request :limits, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-v2.html#compute_limits'

    param :tenant_id, required: false

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      url = "#{ base_url }/limits"

      filters = []

      optional_params.each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      url += "?#{ filters.join('&') }" unless filters.empty?

      url
    end

  end

end

