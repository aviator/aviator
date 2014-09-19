module Aviator
  
  define_request :list_keypairs, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-keypairs-v2_getKeypair__v2__tenant_id__os-keypairs_ext-os-keypairs.html'

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      str  = "#{ base_url }/os-keypairs"
    end

  end

end
