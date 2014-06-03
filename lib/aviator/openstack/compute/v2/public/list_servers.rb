module Aviator

  define_request :list_servers, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/List_Servers-d1e2078.html'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_listServers_v2__tenant_id__servers_compute_servers.html'

    link 'github :issue => getting all servers',
         'https://github.com/aviator/aviator/issues/35'
         
    link 'related mailing list discussion',
         'https://lists.launchpad.net/openstack/msg24695.html'

    param :all_tenants,    :required => false
    param :details,        :required => false
    param :flavor,         :required => false
    param :image,          :required => false
    param :limit,          :required => false
    param :marker,         :required => false
    param :server,         :required => false
    param :status,         :required => false
    param 'changes-since', :required => false, :alias => :changes_since


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      str  = "#{ base_url }/servers"
      str += "/detail" if params[:details]

      filters = []

      (optional_params + required_params - [:details]).each do |param_name|
        value = param_name == :all_tenants && params[param_name] ? 1 : params[param_name] 
        filters << "#{ param_name }=#{ value }" if value
      end

      str += "?#{ filters.join('&') }" unless filters.empty?

      str
    end

  end

end
