# get_user
# create_user
# update_user
# delete_user
# delete_role_from_user_on_tenant
# add_role_to_user_on_tenant
# list_users_for_a_tenant
# list_users
module Aviator

  define_request :get_user, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :identity
    meta :api_version,   :v3

    link 'documentation',
      'http://api.openstack.org/api-ref-identity-v3.html#User_Calls'


    param :id, required: true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/users/#{ params[:id] }"
    end

  end

end
