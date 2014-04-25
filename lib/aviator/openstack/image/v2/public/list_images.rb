module Aviator

  define_request :list_images, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :image

    link 'documentation', 'http://docs.openstack.org/api/openstack-image-service/2.0/content/list-all-images.html'

    param :limit,            required: false
    param :name,             required: false
    param :marker,           required: false
    param :member_status,    required: false
    param :owner,            required: false
    param :size_max,         required: false
    param :size_min,         required: false
    param :sort_dir,         required: false
    param :sort_keys,        required: false
    param :status,           required: false
    param :visibility,       required: false

    def headers
      super
    end

    def http_method
      :get
    end

    def url
      uri = URI(base_url)
      url = "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v2/images"

      filters = []

      (optional_params - [:sort_keys]).each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      params[:sort_keys].each do |sort_key, value|
        filters << "#{ sort_key }=#{ value }"
      end if params[:sort_keys]

      url += "?#{ filters.join('&') }" unless filters.empty?

      url
    end

  end

end
