module Aviator

  define_request :create_or_import_keypair, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-ext.html#ext-os-keypairs'

    param :name,       required: true
    param :public_key, required: false

    def body
      p = {
        keypair: {
          name: params[:name]
        }
      }

      optional_params.each do |key|
        p[:keypair][key] = params[key] if params[key]
      end

      p
    end

    def headers
      super
    end

    def http_method
      :post
    end

    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      "#{ service_spec[:endpoints][0][:adminURL] }/os-keypairs"
    end

  end

end