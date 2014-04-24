module Aviator

  define_request :update_quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute
    meta :api_version,  :v3

    link 'documentation',
      'http://api.openstack.org/api-ref-compute-v3.html#v3quotasets'

    param :tenant_id,                   required: true
    param :cores,                       required: false
    param :fixed_ips,                   required: false
    param :floating_ips,                required: false
    param :force,                       required: false
    param :injected_file_content_bytes, required: false
    param :injected_file_path_bytes,    required: false
    param :injected_files,              required: false
    param :instances,                   required: false
    param :key_pairs,                   required: false
    param :metadata_items,              required: false
    param :ram,                         required: false
    param :security_group_rules,        required: false
    param :security_groups,             required: false

    def body
      p = {
        quota_set: {}
      }

      (optional_params - [:force]).each do |attr|
        p[:quota_set][attr] = params[attr] if params[attr]
      end

      p[:force] = 'True' if params[:force]

      p
    end


    def headers
      super
    end


    def http_method
      :put
    end


    def url
      service_spec = session_data[:catalog].find{|s| s[:type] == 'computev3' }
      v3_url = service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url]
      "#{ v3_url }/os-quota-sets/#{ params[:tenant_id] }"
    end

  end

end
