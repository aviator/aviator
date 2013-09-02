Aviator.define_request :create_tenant do

  provider      :openstack
  service       :identity
  api_version   :v2
  endpoint_type :admin
  
  http_method   :post

  link_to 'documentation',
          'http://docs.openstack.org/api/openstack-identity-service/2.0/content/POST_addTenant_v2.0_tenants_.html'

  required_param :name
  required_param :description
  required_param :enabled


  def url
    service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
    "#{ service_spec[:endpoints][0][:adminURL] }/tenants"
  end

  
  def headers
    h = {}
    
    unless self.anonymous?
      h['X-Auth-Token'] = session_data[:access][:token][:id]
    end

    h
  end
  

  def body
    {
      tenant: {
        name:        params[:name],
        description: params[:description],
        enabled:     params[:enabled]
      }
    }
  end

end
