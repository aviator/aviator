module Aviator

  define_request :change_admin_password do

    meta :provider,      :openstack
    meta :service,       :compute
    meta :api_version,   :v2
    meta :endpoint_type, :public

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Change_Password-d1e3234.html'

    link 'additional spec',
         'https://answers.launchpad.net/nova/+question/228462'

    param :adminPass, required: true
    param :id,        required: true


    def body
      p = {
        changePassword: {
          adminPass: params[:adminPass]
        }
      }

      p
    end


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:access][:token][:id]
      end

      h
    end


    def http_method
      :post
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service.to_s }
      "#{ service_spec[:endpoints][0][:publicURL] }/servers/#{ params[:id] }/action"
    end

  end

end
