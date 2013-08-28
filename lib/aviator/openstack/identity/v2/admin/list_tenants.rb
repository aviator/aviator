define_request :list_tenants do

  endpoint_type :admin
  api_version   :v2
  http_method   :get


  optional_param :marker
  optional_param :limit


  def url
    service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
    str = "#{ service_spec[:endpoints][0][:adminURL] }/tenants"
    
    filters = []
    
    (optional_params + required_params).each do |param_name|
      filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
    end
    
    str += "?#{ filters.join('&') }" unless filters.empty?
    
    str
  end

  
  def headers
    h = {}
    
    unless self.anonymous?
      h['X-Auth-Token'] = session_data[:access][:token][:id]
    end

    h
  end
  
end
