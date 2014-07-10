module Aviator

  define_request :list_snapshots, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service,        :volume
    meta :api_version,    :v2

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/GET_getSnapshotsSimple__v2__tenant_id__snapshots_Snapshots.html'

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/GET_getSnapshotsDetail__v2__tenant_id__snapshots_detail_Snapshots.html'

    param :all_tenants,    required: false
    param :detail,         required: false

    def headers
      super
    end

    def http_method
      :get
    end

    def url
      service_spec = session_data[:catalog].find{|s| s[:type] == 'volumev2' }
      v2_url = service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url]

      str = "#{ v2_url }/snapshots"
      str += "/detail" if params[:detail]

      filters = []

      (optional_params + required_params - [:detail]).each do |param_name|
        value = param_name == :all_tenants && params[param_name] ? 1 : params[param_name]
        filters << "#{ param_name }=#{ value }" if value
      end

      str += "?#{ filters.join('&') }" unless filters.empty?
      str
    end

  end

end
