module Aviator

  define_request :update_quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
      'http://api.openstack.org/api-ref-compute-v2-ext.html#ext-os-quota-sets'

    link 'documentation',
      'http://docs.openstack.org/api/openstack-compute/2/content/PUT_os-quota-sets-v2_updateQuota_v2__tenant_id__os-quota-sets__tenant_id__ext-os-quota-sets.html'


    param :tenant_id,                   required: true
    param :cores,                       required: false
    param :fixed_ips,                   required: false
    param :floating_ips,                required: false
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

      optional_params.each do |attr|
        p[:quota_set][attr] = params[attr] if params[attr]
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
