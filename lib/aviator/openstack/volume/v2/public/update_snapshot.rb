module Aviator

  define_request :update_snapshot, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service,        :volume
    meta :api_version,    :v2

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/PUT_updateSnapshot__v2__tenant_id__snapshots__snapshot_id__Snapshots.html'

    param :snapshot_id,         required: true, alias: :id
    param :display_name,        required: false
    param :display_description, required: false

    def body
      p = {
        snapshot: {}
      }

      optional_params.each do |key|
        p[:snapshot][key] = params[key] if params[key]
      end

      p
    end

    def headers
      super
    end

    def http_method
      :put
    end

    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'volumev2' }
      v2_url = service_spec[:endpoints][0][:adminURL]
      "#{ v2_url }/snapshots/#{ params[:snapshot_id] }"
    end
  end

end
