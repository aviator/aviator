module Aviator

  define_request :create_keypair, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-keypairs-v2_createKeypair__v2__tenant_id__os-keypairs_ext-os-keypairs.html'

    param :name,        :required => true
    param :public_key,  :required => false

    def body
      {
        :keypair => {
          :name       => params[:name],
          :public_key => params[:public_key],
        }
      }
    end


    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/os-keypairs"
    end

  end

end
