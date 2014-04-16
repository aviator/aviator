module Aviator

  define_request :update_quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service,      :volume
    meta :api_version,  :v1

    link 'documentation',
      'http://docs.openstack.org/trunk/openstack-ops/content/projects_users.html'
    link 'documentation',
      'https://github.com/openstack/python-cinderclient/blob/master/cinderclient/v1/quotas.py'

    param :tenant_id, required: true
    param :gigabytes, required: false
    param :snapshots, required: false
    param :volumes,   required: false


    def body
      p = {
        quota_set: {}
      }

      optional_params.each do |attr|
        p[:quota_set][attr] = params[attr].to_i if params[attr]
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
      "#{ base_url }/os-quota-sets/#{ params[:tenant_id] }"
    end

  end

end
