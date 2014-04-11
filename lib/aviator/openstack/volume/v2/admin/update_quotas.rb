module Aviator

  define_request :update_quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service,      :volume
    meta :api_version,  :v2

    link 'documentation',
      'http://docs.openstack.org/trunk/openstack-ops/content/projects_users.html'
    link 'documentation',
      'https://github.com/openstack/python-cinderclient/blob/master/cinderclient/v2/quotas.py'

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
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'volumev2' }
      v2_url = service_spec[:endpoints][0][:adminURL]
      "#{ v2_url }/os-quota-sets/#{ params[:tenant_id] }"
    end

  end

end
