define_request :add_tenant do

  endpoint_type :admin
  api_version   :v2
  http_method   :post


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
