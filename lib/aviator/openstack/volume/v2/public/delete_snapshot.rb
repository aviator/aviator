module Aviator

  define_request :delete_snapshot, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service,        :volume
    meta :api_version,    :v2

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/DELETE_deleteSnapshot__v2__tenant_id__snapshots__snapshot_id__Snapshots.html'

    param :snapshot_id, required: true, alias: :id

    def headers
      super
    end

    def http_method
      :delete
    end

    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'volumev2' }
      v2_url = service_spec[:endpoints][0][:adminURL]
      "#{ v2_url }/snapshots/#{ params[:snapshot_id] }"
    end
  end

end
