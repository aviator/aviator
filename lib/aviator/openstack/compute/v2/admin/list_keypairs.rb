module Aviator

  define_request :list_keypairs, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-ext.html#ext-os-keypairs'

    def headers
      super
    end

    def http_method
      :get
    end

    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      "#{ service_spec[:endpoints][0][:adminURL] }/os-keypairs"
    end

  end

end