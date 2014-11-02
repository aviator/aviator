require 'cgi'

module Aviator

  define_request :get_user, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/GET_getUserByName_v2.0_users__User_Operations.html'

    param :name, :required => true

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/users?name=#{ CGI::escape(params.name) }"
    end

  end

end
