module Aviator

  define_request :update_tenant, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :identity


    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/POST_updateTenant_v2.0_tenants__tenantId__.html'


    param :id,          :required => true
    param :name,        :required => false
    param :enabled,     :required => false
    param :description, :required => false


    def body
      p = {
        :tenant => {}
      }

      [:name, :enabled, :description].each do |key|
        p[:tenant][key] = params[key] if params[key]
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
      "#{ base_url }/tenants/#{ params[:id] }"
    end

  end

end
