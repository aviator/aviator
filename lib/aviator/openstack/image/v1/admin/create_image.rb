module Aviator

  define_request :create_image, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service,      :image
    meta :api_version,  :v1

    link 'documentation', 'http://docs.openstack.org/api/openstack-image-service/1.1/content/adding-a-new-virtual-machine-image.html'

    param :id,                required: false
    param :name,              required: false
    param :disk_format,       required: false
    param :container_format,  required: false
    param :store,             required: false
    param :owner,             required: false
    param :min_ram,           required: false
    param :min_disk,          required: false
    param :checksum,          required: false
    param :is_public,         required: false
    param :is_protected,      required: false
    param :copy_from,         required: false
    param :file,              required: false
    param :properties,        required: false

    def headers
      h = {
        'X-Auth-Token'                  => session_data[:access][:token][:id],
        'Content-Type'                  =>'application/octet-stream',
        'x-image-meta-id'               => params[:id],
        'x-image-meta-name'             => params[:name],
        'x-image-meta-disk-format'      => params[:disk_format],
        'x-image-meta-container-format' => params[:container_format],
        'x-image-meta-store'            => params[:store],
        'x-image-meta-owner'            => params[:owner],
        'x-image-meta-min-ram'          => params[:min_ram],
        'x-image-meta-min-disk'         => params[:min_disk],
        'x-image-meta-checksum'         => params[:checksum],
        'x-image-meta-is-public'        => params[:is_public],
        'x-image-meta-protected'        => params[:is_protected],
        'x-glance-api-copy-from'        => params[:copy_from]
      }

      @request_body = nil

      if params[:copy_from].nil? and not params[:file].nil?
        file                    = Faraday::UploadIO.new(params[:file], 'application/octet-stream')
        @request_body           = file.io
        h['x-image-meta-size']  = file.size.to_s
      end

      unless params[:properties].nil?
        params[:properties].each { |k, v| h["x-image-meta-property-#{k}"] = v }
      end

      h.reject { |k,v| v.nil? }
    end

    def body
      { file: @request_body }
    end

    def http_method
      :post
    end

    def url
      uri = URI(base_url)
      "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v1/images"
    end

    undef_method :body unless @request_body

  end

end