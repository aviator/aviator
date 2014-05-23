module Aviator

  define_request :grant_role_to_user_on_domain, inherit: [:openstack, :common, :v3, :public, :base] do

    meta :service,      :identity
    meta :api_version,  :v3

    link 'documentation',
      'https://github.com/openstack/identity-api/blob/master/v3/src/markdown/identity-api-v3.md#grant-role-to-user-on-domain-put-domainsdomain_idusersuser_idrolesrole_id'

    param :domain_id, required: true
    param :role_id,   required: true
    param :user_id,   required: true


    def headers
      super
    end


    def http_method
      :put
    end


    def url
      "#{ base_url }/domains/#{ params[:domain_id] }/users/#{ params[:user_id] }/roles/#{ params[:role_id] }"
    end

  end

end