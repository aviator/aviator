module Aviator

  define_request :list_volumes, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service,        :volume
    meta :api_version,    :v1

    link 'documentation', 'http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolumesSimple_v1__tenant_id__volumes_v1__tenant_id__volumes.html'

    param :all_tenants,         :required => false
    param :details,             :required => false
    param :status,              :required => false
    param :availability_zone,   :required => false
    param :bootable,            :required => false
    param :display_name,        :required => false
    param :display_description, :required => false
    param :volume_type,         :required => false
    param :snapshot_id,         :required => false
    param :size,                :required => false


    def headers
      super
    end

    def http_method
      :get
    end

    def url
      str  = "#{ base_url }/volumes"
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
