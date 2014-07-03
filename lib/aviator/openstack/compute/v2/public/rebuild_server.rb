module Aviator

  define_request :rebuild_server, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Rebuild_Server-d1e3538.html'

    param :accessIPv4,  :required => false, :alias => :access_ipv4
    param :accessIPv6,  :required => false, :alias => :access_ipv6
    param :adminPass,   :required => true,  :alias => :admin_pass
    param :id,          :required => true
    param :imageRef,    :required => true,  :alias => :image_ref
    param :metadata,    :required => false
    param :name,        :required => true
    param :personality, :required => false


    def body
      p = {
        :rebuild => {
          :adminPass => params[:adminPass],
          :imageRef  => params[:imageRef],
          :name      => params[:name]
        }
      }
      
      [:accessIPv4, :accessIPv6, :metadata, :personality].each do |key|
        p[:rebuild][key] = params[key] if params[key]
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
      "#{ base_url }/servers/#{ params[:id] }/action"
    end

  end

end
