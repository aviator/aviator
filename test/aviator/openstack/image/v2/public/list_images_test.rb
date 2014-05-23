require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/image/v2/public/list_images' do

    def create_request(session_data = get_session_data, &block)
      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'image', 'v2', 'public', 'list_images.rb')
    end


    def session
      unless @session
        @session = Aviator::Session.new(
                     config_file: Environment.path,
                     environment: 'openstack_member'
                   )
        @session.authenticate
      end

      @session
    end


    def v2_base_url
      unless @v2_base_url
        #binding.pry
        @v2_base_url = get_session_data[:catalog].find { |s| s[:type] == 'image' }[:endpoints].find{|a| a[:interface] == 'public'}[:url]
        @v2_base_url << '/v2'
      end

      @v2_base_url
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_attr :body do
      klass.body?.must_equal false
      create_request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data.token }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :limit,
        :name,
        :marker,
        :member_status,
        :owner,
        :size_max,
        :size_min,
        :sort_dir,
        :sort_keys,
        :status,
        :visibility
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :url do
      v2_base_url = get_session_data[:catalog].find { |s| s[:type] == 'image' }[:endpoints].find{|a| a[:interface] == 'public'}[:url]
      url         = "#{ v2_base_url }/v2/images"
      request     = klass.new(get_session_data)

      request.url.must_equal url
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_response 'no parameters are provided' do
      response = session.image_service.request(:list_images, api_version: :v2)

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:images].length.wont_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'filtering with matches' do
      response = session.image_service.request(:list_images, api_version: :v2) do |p|
        p[:name] = 'cirros-0.3.1-x86_64-uec'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:images].length.must_equal 1
      response.headers.wont_be_nil
    end


    validate_response 'filtering with sort keys' do
      response = session.image_service.request(:list_images, api_version: :v2) do |p|
        p[:sort_keys] = {
          min_disk: 0,
          min_ram: 0
        }
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:images].map{|i| i[:min_disk]}.uniq.must_equal [0]
      response.body[:images].map{|i| i[:min_ram]}.uniq.must_equal [0]
      response.headers.wont_be_nil
    end


    validate_response 'filtering with no matches' do
      response = session.image_service.request(:list_images, api_version: :v2) do |p|
        p[:name] = 'does-not-match-any-image'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:images].length.must_equal 0
      response.headers.wont_be_nil
    end

  end
end
