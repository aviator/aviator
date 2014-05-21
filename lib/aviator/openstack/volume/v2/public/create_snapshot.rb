module Aviator

  define_request :create_snapshot, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service,        :volume
    meta :api_version,    :v2

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/POST_createSnapshot__v2__tenant_id__snapshots_Snapshots.html'

    param :volume_id,           required: true
    param :force,               required: false
    param :name,        required: true
    param :description, required: true

    def body
      {
        snapshot: {
         name:          params[:name],
         description:   params[:description],
         volume_id:             params[:volume_id],
         force:                 params[:force] || false
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
      service_spec = session_data[:catalog].find{|s| s[:type] == 'volumev2' }
      v2_url = service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url]
      "#{ v2_url }/snapshots"
    end
  end

end
