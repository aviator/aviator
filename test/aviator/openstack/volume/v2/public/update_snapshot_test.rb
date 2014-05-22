
require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/volume/v2/public/update_snapshot' do

    def create_snapshot
      response = session.volume_service.request :create_volume, base_url: v1_base_url do |params|
        params[:name]         = 'Volume for Update Snapshot'
        params[:description]  = 'Volume for Update Snapshot Description'
        params[:size]                 = '1'
      end
      @volume = response.body[:volume]

      response = session.volume_service.request(:create_snapshot, base_url: v2_base_url) do |params|
        params[:name]         = 'Snapshot for Update Test'
        params[:description]  = 'Snapshot for Update Test Description'
        params[:volume_id]            =  @volume[:id]
        params[:force]                =  true
      end

      #sleep 5
      response.body[:snapshot]
    end

    def get_session_data
      session.send :auth_info
    end

    def helper
      Aviator::Test::RequestHelper
    end

    def klass
      @klass ||= helper.load_request('openstack', 'volume', 'v2', 'public', 'update_snapshot.rb')
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

    def v1_base_url
      unless @v1_base_url
        @v1_base_url = get_session_data[:catalog].find { |s| s[:type] == 'volume' }[:endpoints].find{|a| a[:interface] == 'admin'}[:url]
      end

      @v1_base_url
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
      snapshot = create_snapshot

      snapshot.wont_be_empty

      snapshot_name = "Updated Snapshot Name"
      #update snapshot
      response = session.volume_service.request(:update_snapshot, base_url: v2_base_url) do |params|
        params[:snapshot_id] = snapshot[:id]
        params[:name] = snapshot_name
      end

      response.status.must_equal 200
      response.body[:snapshot].wont_be_nil
      response.body[:snapshot][:name].must_equal snapshot_name

      #delete snapshot
      response = session.volume_service.request(:delete_snapshot, base_url: v2_base_url) do |params|
        params[:snapshot_id] = snapshot[:id]
      end

      #sleep 5
      #delete volume
      response = session.volume_service.request(:delete_volume, base_url: v1_base_url) do |params|
        params[:id] = @volume[:id]
      end
    end

  end

end
