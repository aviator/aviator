define_request :list_images do

  endpoint_type :public
  api_version   :v2
  http_method   :get

  optional_param :show_details
  optional_param :server
  optional_param :name
  optional_param :status
  optional_param :changes_since
  optional_param :marker
  optional_param :limit
  optional_param :type



  def url
    service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
    
    str  = "#{ service_spec[:endpoints][0][:publicURL] }/images"
    str += "/detail" if params[:show_details]
    
    filters = []
    
    (optional_params + required_params - [:show_details]).each do |param_name|
      query_key = (param_name == :changes_since ? 'changes-since' : param_name)
      
      filters << "#{ query_key }=#{ params[param_name] }" if params[param_name]
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
