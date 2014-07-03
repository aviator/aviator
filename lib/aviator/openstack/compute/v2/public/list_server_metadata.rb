module Aviator

  define_request :list_server_metadata, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
      'http://docs.openstack.org/api/openstack-compute/2/content/List_Metadata-d1e5089.html'


    param :id, :required => true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/servers/#{ params[:id] }/metadata"
    end

  end

end
