module Aviator

  define_request :list_hosts, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref.html#ext-os-hosts'

    link 'documentation bug',
         'https://bugs.launchpad.net/nova/+bug/1224763'

    param :service, :required => false
    param :zone,    :required => false


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      url = "#{ base_url }/os-hosts"

      filters = []

      optional_params.each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      url += "?#{ filters.join('&') }" unless filters.empty?

      url
    end

  end

end

