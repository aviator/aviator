require 'test_helper'

class Aviator::Test

  describe 'aviator/providers/openstack/compute/v2/public/list_flavors' do

    def create_request(session_data = get_session_data)
      klass.new(session_data)
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


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'list_flavors.rb')
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
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request(get_session_data)

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :details,
        :minDisk,
        :minRam,
        :marker,
        :limit
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/flavors"

      params = [
        [ :details, true                              ],
        [ :minDisk, 2                                 ],
        [ :minRam,  'cirros-0.3.1-x86_64-uec-ramdisk' ],
        [ :marker,  '123456'                          ],
        [ :limit,   10                                ]
      ]

      url += "/detail" if params.find{|pair| pair[0] == :details && pair[1] == true }

      filters = []

      params.select{|pair| pair[0]!=:details }.each{ |pair| filters << "#{ pair[0] }=#{ pair[1] }" }

      url += "?#{ filters.join('&') }" unless filters.empty?

      request = klass.new(get_session_data) do |p|
        params.each { |pair| p[pair[0]] = pair[1] }
      end

      request.url.must_equal url
    end


    validate_attr :param_aliases do
      aliases = {
        min_disk: :minDisk,
        min_ram:  :minRam
      }

      klass.param_aliases.must_equal aliases
    end


    validate_response 'no parameters are provided' do
      response = session.compute_service.request :list_flavors

      response.status.must_equal 200
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'the details filter is provided' do
      response = session.compute_service.request :list_flavors do |params|
        params[:details] = true
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:flavors].length.wont_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'the minDisk filter is provided' do
      response = session.compute_service.request :list_flavors do |params|
        params[:details] = true
      end

      max_disk_size = response.body[:flavors].max{|a,b| a[:disk] <=> b[:disk] }[:disk]
      total_entries = response.body[:flavors].count{|flv| flv[:disk] == max_disk_size }

      response = session.compute_service.request :list_flavors do |params|
        params[:minDisk] = max_disk_size
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:flavors].length.must_equal total_entries
      response.headers.wont_be_nil
    end

  end

end
