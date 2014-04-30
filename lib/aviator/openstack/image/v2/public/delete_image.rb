module Aviator

  define_request :delete_image, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :image

    link 'documentation', 'http://docs.openstack.org/api/openstack-image-service/2.0/content/delete-an-image.html'

    param :image_id, required: true, alias: :id

    def headers
      super
    end

    def http_method
      :delete
    end

    def url
      uri = URI(base_url)
      "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v2/images/#{ params[:image_id] }"
    end

  end

end