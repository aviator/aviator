require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/volume/v2/public/get_snapshot_details' do

    def create_snapshot
      response = session.volume_service.request :create_volume, api_version: :v1 do |params|
        params[:display_name]         = 'Volume for Get Snapshot Details'
        params[:display_description]  = 'Volume for Get Snapshot Details Description'
        params[:size]                 = '1'
      end
      @volume = response.body[:volume]

      response = session.volume_service.request(:create_snapshot, api_version: :v2) do |params|
        params[:name]         = 'Snapshot for Get Details Test'
        params[:description]  = 'Snapshot for Get Details Test Description'
        params[:volume_id]    =  @volume[:id]
        params[:force]        =  true
      end

      # sleep 5
      response.body[:snapshot]
    end

    def get_session_data
      session.send :auth_info
    end

    def helper
      Aviator::Test::RequestHelper
    end

    def klass
      @klass ||= helper.load_request('openstack', 'volume', 'v2', 'public', 'get_snapshot_details.rb')
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


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_response 'parameters are provided' do
      snapshot = create_snapshot

      snapshot.wont_be_empty

      #get_snapshot_details
      response = session.volume_service.request(:get_snapshot_details, api_version: :v2) do |params|
        params[:snapshot_id] = snapshot[:id]
      end

      response.status.must_equal 200
      response.body[:snapshot].wont_be_nil
      response.body[:snapshot][:name].must_equal snapshot[:name]


      #delete snapshot
      response = session.volume_service.request(:delete_snapshot, api_version: :v2) do |params|
        params[:snapshot_id] = snapshot[:id]
      end

      # sleep 5
      #delete volume
      response = session.volume_service.request(:delete_volume, api_version: :v1) do |params|
        params[:id] = @volume[:id]
      end
    end

  end

end
