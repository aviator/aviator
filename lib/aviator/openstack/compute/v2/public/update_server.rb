module Aviator

  define_request :update_server, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/ServerUpdate.html'

    param :accessIPv4, required: false
    param :accessIPv6, required: false
    param :id,         required: true
    param :name,       required: false


    def body
      p = {
        server: { }
      }

      [:name, :accessIPv4, :accessIPv6].each do |key|
        p[:server][key] = params[key] if params[key]
      end

      p
    end


    def headers
      super
    end


    def http_method
      :put
    end


    def url
      "#{ base_url_for :public }/servers/#{ params[:id] }"
    end

  end

end
