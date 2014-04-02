module Aviator

  define_request :list_keypairs, inherit: [:openstack, :common, :v2, :public, :base] do

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
      "#{ base_url }/os-keypairs"
    end

  end

end