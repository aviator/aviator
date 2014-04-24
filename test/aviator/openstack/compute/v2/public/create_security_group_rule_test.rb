require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/create_security_group_rule' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:ip_protocol] = 'TCP'
                  params[:from_port] = '80'
                  params[:to_port] = '80'
                  params[:cidr] = '0.0.0.0/0'
                  params[:parent_group_id] = 1
                end
      klass.new(session_data, &block)
    end

    def get_session_data
      session.send :auth_info
    end

    def helper
      Aviator::Test::RequestHelper
    end

    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'create_security_group_rule.rb')
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
      headers = { 'X-Auth-Token' => get_session_data.token }

      request = create_request

      request.headers.must_equal headers
    end

    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end

    validate_attr :optional_params do
      klass.optional_params.must_equal [:group_id]
    end

    validate_attr :required_params do
      klass.required_params.must_equal [
        :ip_protocol,
        :from_port,
        :to_port,
        :cidr,
        :parent_group_id
      ]
    end

    validate_attr :url do
      service_spec = get_session_data[:catalog].find{ |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints].find{|e| e[:interface] == 'public'}[:url] }/os-security-group-rules"

      request = create_request

      request.url.must_equal url
    end

    validate_response 'valid parameters are provided' do
      sec_group_rule_keys = %w[
        from_port group ip_protocol to_port parent_group_id ip_range id
      ].sort
      sec_group_id = session.compute_service.request(:list_security_groups)
                      .body[:security_groups].first[:id]

      response = session.compute_service.request :create_security_group_rule do |params|
        params[:ip_protocol]      = 'TCP'
        params[:from_port]        = '6555'
        params[:to_port]          = '6555'
        params[:cidr]             = '0.0.0.0/0'
        params[:parent_group_id]  = sec_group_id
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:security_group_rule].keys.sort.must_equal sec_group_rule_keys
      response.body[:security_group_rule][:parent_group_id].must_equal sec_group_id
      response.headers.wont_be_nil
    end

    validate_response 'existing rule parameters are provided' do
      sec_group_id = session.compute_service.request(:list_security_groups)
                      .body[:security_groups].first[:id]

      session.compute_service.request :create_security_group_rule do |params|
        params[:ip_protocol]      = 'TCP'
        params[:from_port]        = '6789'
        params[:to_port]          = '6789'
        params[:cidr]             = '0.0.0.0/0'
        params[:parent_group_id]  = sec_group_id
      end

      sec_group = session.compute_service.request(:list_security_groups)
                      .body[:security_groups].first
      existing_rule = sec_group[:rules].first

      response = session.compute_service.request :create_security_group_rule do |params|
        params[:ip_protocol]      = existing_rule[:ip_protocol]
        params[:from_port]        = existing_rule[:from_port]
        params[:to_port]          = existing_rule[:to_port]
        params[:cidr]             = existing_rule[:ip_range][:cidr]
        params[:parent_group_id]  = sec_group[:id]
      end

      response.status.must_equal 400
      response.body.wont_be_nil
      response.body["badRequest"].wont_be_nil
      response.body["badRequest"]["message"].must_match /^This rule already exists/
      response.headers.wont_be_nil
    end

    validate_response 'invalid IP protocol is provided' do
      invalid_protocol = 'XXX'

      response = session.compute_service.request :create_security_group_rule do |params|
        params[:ip_protocol]      = invalid_protocol
        params[:from_port]        = '6789'
        params[:to_port]          = '6789'
        params[:cidr]             = '0.0.0.0/0'
        params[:parent_group_id]  = 1
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
      response.body.wont_be_nil
      response.body["badRequest"].wont_be_nil
      response.body["badRequest"]["message"].must_equal "Invalid IP protocol #{ invalid_protocol }."
    end

    validate_response 'invalid CIDR is provided' do
      invalid_cidr = 'malformedinvalid~!'

      response = session.compute_service.request :create_security_group_rule do |params|
        params[:ip_protocol]      = 'TCP'
        params[:from_port]        = '6789'
        params[:to_port]          = '6789'
        params[:cidr]             = invalid_cidr
        params[:parent_group_id]  = 1
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
      response.body.wont_be_nil
      response.body["badRequest"].wont_be_nil
      response.body["badRequest"]["message"].must_equal "Invalid cidr #{ invalid_cidr }."
    end

    validate_response 'from port is greater than to port' do
      from_port = 50
      to_port   = 30

      response = session.compute_service.request :create_security_group_rule do |params|
        params[:ip_protocol]      = 'TCP'
        params[:from_port]        = from_port
        params[:to_port]          = to_port
        params[:cidr]             = '0.0.0.0/0'
        params[:parent_group_id]  = 1
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
      response.body.wont_be_nil
      response.body["badRequest"].wont_be_nil
      response.body["badRequest"]["message"].must_equal "Invalid port range #{ from_port }:#{ to_port }. Former value cannot be greater than the later"
    end

    validate_response 'port range is beyond allowed port numbers' do
      from_port = 80
      to_port   = 65536

      response = session.compute_service.request :create_security_group_rule do |params|
        params[:ip_protocol]      = 'TCP'
        params[:from_port]        = from_port
        params[:to_port]          = to_port
        params[:cidr]             = '0.0.0.0/0'
        params[:parent_group_id]  = 1
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
      response.body.wont_be_nil
      response.body["badRequest"].wont_be_nil
      response.body["badRequest"]["message"].must_equal "Invalid port range #{ from_port }:#{ to_port }. Valid TCP ports should be between 1-65535"
    end

  end
end