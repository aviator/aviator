module Aviator

  define_request :create_tenant, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :identity

    link 'documentation',
         'http://docs.openstack.org/api/openstack-identity-service/2.0/content/'


    param :name,        :required => true
    param :description, :required => true
    param :enabled,     :required => true


    def body
      {
        :tenant => {
          :name        => params[:name],
          :description => params[:description],
          :enabled     => params[:enabled]
        }
      }
    end


    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/tenants"
    end

  end

end