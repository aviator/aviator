module Aviator

  define_request :set_server_metadata, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Create_or_Replace_Metadata-d1e5358.html'


    param :id,       :required => true
    param :metadata, :required => true


    def body
      {
        :metadata => params[:metadata]
      }
    end


    def headers
      super
    end


    def http_method
      :put
    end


    def url
      "#{ base_url }/servers/#{ params[:id] }/metadata"
    end

  end

end
