module Aviator

  define_request :list_public_images, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service,        :image
    meta :api_version,    :v1

    link 'documentation', 'http://docs.openstack.org/api/openstack-image-service/1.1/content/requesting-a-list-of-public-vm-images.html'

    param :name,             :required => false
    param :container_format, :required => false
    param :disk_format,      :required => false
    param :status,           :required => false
    param :size_min,         :required => false
    param :size_max,         :required => false
    param :sort_key,         :required => false
    param :sort_dir,         :required => false


    def headers
      super
    end

    def http_method
      :get
    end

    def url
      uri = URI(base_url)
      url = "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v1/images"

      filters = []

      optional_params.each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      url += "?#{ filters.join('&') }" unless filters.empty?

      url
    end

  end

end
