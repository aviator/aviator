module Aviator

  define_request :create_network, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute.html#ext-os-networks'


    param :label,             :required => true
    param :bridge,            :required => false
    param :bridge_interface,  :required => false
    param :cidr,              :required => false
    param :cidr_v6,           :required => false
    param :dns1,              :required => false
    param :dns2,              :required => false
    param :gateway,           :required => false
    param :gateway_v6,        :required => false
    param :multi_host,        :required => false
    param :project_id,        :required => false
    param :vlan,              :required => false


    def body
      p = {
        :network => {
          :label => params[:label]
        }
      }

      optional_params.each do |key|
        p[:network][key] = params[key] if params[key]
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
      "#{ base_url }/os-networks"
    end

  end

end
