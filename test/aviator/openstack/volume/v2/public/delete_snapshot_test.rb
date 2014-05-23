require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/volume/v2/public/delete_snapshot' do

    def create_snapshot
      response = session.volume_service.request :create_volume, api_version: :v1 do |params|
        params[:display_name]         = 'Volume for Delete Snapshot'
        params[:display_description]  = 'Volume for Delete Snapshot Description'
        params[:size]                 = '1'
      end
      @volume = response.body[:volume]

      response = session.volume_service.request(:create_snapshot, api_version: :v2) do |params|
        params[:name]         = 'Snapshot for Delete Test'
        params[:description]  = 'Snapshot for Delete Test Description'
        params[:volume_id]    =  @volume[:id]
        params[:force]        =  true
      end

      # sleep 5
      @snapshot = response.body[:snapshot]
    end

    def get_session_data
      session.send :auth_info
    end

    def helper
      Aviator::Test::RequestHelper
    end

    def klass
      @klass ||= helper.load_request('openstack', 'volume', 'v2', 'public', 'delete_snapshot.rb')
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

      #delete snapshot
      response = session.volume_service.request(:delete_snapshot, api_version: :v2) do |params|
        params[:snapshot_id] = snapshot[:id]
      end

      response.status.must_equal 202

      # sleep 5

      list = session.volume_service.request(:list_snapshots, api_version: :v2)
      list.body[:snapshots].collect{ |s| s[:id] }.include?(snapshot[:id]).must_equal false

      # sleep 5
      #delete volume
      response = session.volume_service.request(:delete_volume, api_version: :v1) do |params|
        params[:id] = @volume[:id]
      end
    end

  end

end
