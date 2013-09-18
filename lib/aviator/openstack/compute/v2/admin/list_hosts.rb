module Aviator

  define_request :list_hosts do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
      'http://api.openstack.org/api-ref.html#ext-os-hosts'

    link 'documentation bug',
         'https://bugs.launchpad.net/nova/+bug/1224763'

    param :service, required: false
    param :zone,    required: false


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:access][:token][:id]
      end

      h
    end


    def http_method
      :get
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find { |s| s[:type] == service.to_s }

      url = "#{ service_spec[:endpoints][0][:adminURL] }/os-hosts"

      filters = []

      optional_params.each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      url += "?#{ filters.join('&') }" unless filters.empty?

      url
    end

  end

end

