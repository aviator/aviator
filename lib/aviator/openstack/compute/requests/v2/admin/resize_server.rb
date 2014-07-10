module Aviator

  define_request :resize_server, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Resize_Server-d1e3707.html'

    param :id,        :required => true
    param :name,      :required => true
    param :flavorRef, :required => true, :alias => :flavor_ref


    def body
      {
        :resize => {
          :name      => params[:name],
          :flavorRef => params[:flavorRef]
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
      "#{ base_url }/servers/#{ params[:id] }/action"
    end

  end

end
