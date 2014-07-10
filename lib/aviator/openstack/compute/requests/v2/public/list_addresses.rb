module Aviator

  define_request :list_addresses, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/List_Addresses-d1e3014.html'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/List_Addresses_by_Network-d1e3118.html'


    param :id,        :required => true
    param :networkID, :required => false, :alias => :network_id


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      url  = "#{ base_url }/servers/#{ params[:id] }/ips"
      url += "/#{ params[:networkID] }" if params[:networkID]
      url
    end

  end

end
