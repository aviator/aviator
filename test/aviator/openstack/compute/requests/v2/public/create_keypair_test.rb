require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/requests/v2/public/create_keypair' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:name]       = 0
                  params[:public_key] = 'thisdoesnotmatter'
                end

      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_response
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'create_keypair.rb')
    end


    def session
      unless @session
        @session = Aviator::Session.new(
                     :config_file => Environment.path,
                     :environment => 'openstack_member'
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


    validate_attr :body do
      request = create_request

      klass.body?.must_equal true
      request.body?.must_equal true
      request.body.wont_be_nil
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:body][:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :public_key
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal [
        :name
      ]
    end


    validate_attr :url do
      service_spec = get_session_data[:body][:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/os-keypairs"

      request = create_request do |params|
        params[:name] = 'somename'
      end

      request.url.must_equal url
    end


    validate_response 'valid parameters are provided' do
      response = session.compute_service.request :create_keypair, :api_version => :v2 do |params|
        params[:name] = 'new-keypair'
        params[:public_key] = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSEPMGA4D7oF4ObBb3vbufLmK2oKyJQu0Ol4fyGAS+X342prm7dvVF5lCxVrtXzADDkFZJF0TE+3mjgywzciH2dy9+z7E/YNdQpr4tXFWSrjAy+zi+Lw7s2QuScdg55/uSLiiuuTAI2Gfm4K+QxEiNRStdUqXS3p6v6PDfLwEOJwaOL639yR5Ivk+Nf3BG79OPcmCIkTw7yzQn54UHAZ7RoH/yrXQEUd4uOCA2Kwa3imP7TeIcvKl/h0EjgLK6Q/lI5diziCPVVheh1NMd0prcfu7HXz4W9dxlJaX8YDQwXT5YH+F0JE/D0pq3M/tQSw1dftz+E4FVjUqFWnnaxD/p bogus.rsa@key.com"
      end

      response.status.must_equal 200
      response.headers.wont_be_nil
      response.body['keypair'].wont_be_nil
    end


    validate_response 'an invalid public key is provided' do
      response = session.compute_service.request :create_keypair, :api_version => :v2 do |params|
        params[:name] = 'invalid-public-key'
        params[:public_key] = "invalid"
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
      response.body['keypair'].must_be_nil
    end


  end

end
