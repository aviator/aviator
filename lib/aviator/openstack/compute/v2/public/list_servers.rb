module Aviator

  define_request :list_servers do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :public

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/List_Servers-d1e2078.html'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_listServers_v2__tenant_id__servers_compute_servers.html'

    link 'github issue: getting all servers',
         'https://github.com/aviator/aviator/issues/35'
         
    link 'related mailing list discussion',
         'https://lists.launchpad.net/openstack/msg24695.html'

    param :all_tenants,    required: false
    param :details,        required: false
    param :flavor,         required: false
    param :image,          required: false
    param :limit,          required: false
    param :marker,         required: false
    param :server,         required: false
    param :status,         required: false
    param 'changes-since', required: false


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:access][:token][:id]
      end

      h
    end


    def http_method
      :get
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service.to_s }

      str  = "#{ service_spec[:endpoints][0][:publicURL] }/servers"
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
