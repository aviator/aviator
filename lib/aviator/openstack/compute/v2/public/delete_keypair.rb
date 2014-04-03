module Aviator

  define_request :delete_keypair, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-ext.html#ext-os-keypairs'

    param :keypair_name, required: true

    def key_name
      params[:keypair_name].gsub(' ', '%20')
    end

    def headers
      super
    end

    def http_method
      :delete
    end

    def url
      "#{ base_url }/os-keypairs/#{ key_name }"
    end

  end

end