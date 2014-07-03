module Aviator

  define_request :create_server, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/CreateServers.html'

    param :accessIPv4,  :required => false, :alias => :access_ipv4
    param :accessIPv6,  :required => false, :alias => :access_ipv6
    param :adminPass,   :required => false, :alias => :admin_pass
    param :imageRef,    :required => true,  :alias => :image_ref
    param :flavorRef,   :required => true,  :alias => :flavor_ref
    param :metadata,    :required => false
    param :name,        :required => true
    param :networks,    :required => false
    param :personality, :required => false


    def body
      p = {
        :server => {
          :flavorRef => params[:flavorRef],
          :imageRef  => params[:imageRef],
          :name      => params[:name]
        }
      }

      [:adminPass, :metadata, :personality, :networks, :accessIPv4, :accessIPv6].each do |key|
        p[:server][key] = params[key] if params[key]
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
      "#{ base_url }/servers"
    end

  end

end
