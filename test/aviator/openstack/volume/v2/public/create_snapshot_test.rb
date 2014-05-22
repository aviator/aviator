require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/volume/v2/public/create_snapshot' do

    def get_session_data
      session.send :auth_info
    end

    def helper
      Aviator::Test::RequestHelper
    end

    def klass
      @klass ||= helper.load_request('openstack', 'volume', 'v2', 'public', 'create_snapshot.rb')
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
        @v2_base_url = get_session_data[:catalog].find { |s| s[:type] == 'volumev2' }[:endpoints].find{|a| a[:interface] == 'admin'}[:url]
      end

      @v2_base_url
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end



    validate_response 'parameters are provided' do

      volume    = session.volume_service.request(:list_volumes).body['volumes'].first

      response = session.volume_service.request(:create_snapshot, base_url: v2_base_url) do |params|
        params[:name]         = 'Aviator Volume Test Snapshot Name'
        params[:description]  = 'Aviator Volume Test Description'
        params[:volume_id]    =  volume[:id]
        params[:force]        = true
      end

      response.status.must_equal 202
    end

  end

end
