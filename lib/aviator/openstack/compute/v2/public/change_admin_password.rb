module Aviator

  define_request :change_admin_password, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Change_Password-d1e3234.html'

    link 'additional spec',
         'https://answers.launchpad.net/nova/+question/228462'

    param :adminPass, :required => true, :alias => :admin_pass
    param :id,        :required => true


    def body
      p = {
        :changePassword => {
          :adminPass => params[:adminPass]
        }
      }

      p
    end


    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/servers/#{ params[:id] }/action"
    end

  end

end
