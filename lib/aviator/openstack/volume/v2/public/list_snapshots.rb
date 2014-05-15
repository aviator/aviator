module Aviator

  define_request :list_snapshots, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service,        :volume
    meta :api_version,    :v2

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/GET_getSnapshotsSimple__v2__tenant_id__snapshots_Snapshots.html'

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/GET_getSnapshotsDetail__v2__tenant_id__snapshots_detail_Snapshots.html'

    param :detail, required: false

    def headers
      super
    end

    def http_method
      :get
    end

    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'volumev2' }
      v2_url = service_spec[:endpoints][0][:adminURL]
      str = "#{ v2_url }/snapshots"
      str += "/detail" if params[:detail]
      str
    end
  end

end
