module Aviator

  define_request :update_network, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute.html#ext-os-networks'


    param :id,                   required: true
    param :associate_host,       required: false
    param :disassociate,         required: false
    param :disassociate_project, required: false
    param :disassociate_host,    required: false


    def body
      p = {}

      optional_params = [
        :associate_host, :disassociate_project,
        :disassociate_project, :disassociate_host
      ]

      optional_params.each do |key|
        p[key] = params[key] if params[key] == 1
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
      "#{ base_url }/os-networks/#{ params[:id] }/action"
    end

  end

end
