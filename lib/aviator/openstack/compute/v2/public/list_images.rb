define_request :list_images do

  endpoint_type :public
  api_version   :v2
  http_method   :get

  link_to 'documentation',
          'http://docs.openstack.org/api/openstack-compute/2/content/List_Images-d1e4435.html'

  optional_param :details
  optional_param :server
  optional_param :name
  optional_param :status
  optional_param 'changes-since'
  optional_param :marker
  optional_param :limit
  optional_param :type



  def url
    service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
    
    str  = "#{ service_spec[:endpoints][0][:publicURL] }/images"
    str += "/detail" if params[:details]
    
    filters = []
    
    (optional_params + required_params - [:details]).each do |param_name|
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
