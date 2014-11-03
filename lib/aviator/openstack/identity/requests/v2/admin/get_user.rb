require 'uri'

module Aviator

  define_request :get_user do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/GET_getUserByName_v2.0_users__User_Operations.html'

    param :name,      :required => true

    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:body][:access][:token][:id]
      end

      h
    end


    def http_method
      :get
    end


    def url
      service_spec = session_data[:body][:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      "#{ service_spec[:endpoints][0][:adminURL] }/users/?" + URI.encode_www_form(Hash[params.members.zip(params.to_a)])
    end

  end

end
