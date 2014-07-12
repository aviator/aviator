require 'test_helper'

class Aviator::Test

  describe 'aviator/core/service' do

    def config
      Environment.openstack_admin
    end


    def do_auth_request
      request_name = config[:auth_service][:request].to_sym

      bootstrap = {
        :auth_service => config[:auth_service]
      }

      service.request request_name, :session_data => bootstrap do |params|
        config[:auth_credentials].each do |k,v|
          params[k] = v
        end
      end
    end


    def klass
      Aviator::Service
    end


    def service(default_session_data=nil)
      options = {
        :provider => config[:provider],
        :service  => config[:auth_service][:name]
      }

      options[:default_session_data] = default_session_data unless default_session_data.nil?

      klass.new(options)
    end


    describe '#request' do

      it 'can find the correct request based on bootstrapped session data' do
        response = do_auth_request

        response.must_be_instance_of Aviator::Response
        response.request.api_version.must_equal config[:auth_service][:api_version].to_sym
      end


      it 'uses the default session data if session data is not provided' do
        auth_response = do_auth_request
        default_session_data = Hashish.new({
          :headers => auth_response.headers,
          :body    => auth_response.body
        })
        s = service(default_session_data)

        response = s.request :list_tenants

        response.status.must_equal 200
      end


      it 'raises a SessionDataNotProvidedError if there is no session data' do
        the_method = lambda do
          service.request :list_tenants
        end

        the_method.must_raise Aviator::Service::SessionDataNotProvidedError
        error = the_method.call rescue $!
        error.message.wont_be_nil
      end

    end


    describe '#request_classes' do

      it 'returns an array of the request classes' do
        provider_name  = config[:provider]
        service_name    = config[:auth_service][:name]
        provider_module = "Aviator::#{ provider_name.camelize }::Provider".constantize

        request_file_paths = provider_module.request_file_paths(service_name)
        request_file_paths.each{ |path| require path }

        constant_parts = request_file_paths \
                          .map{|rf| rf.to_s.match(/#{ provider_name }\/#{ service_name }\/([\w\/]+)\.rb$/) } \
                          .map{|rf| rf[1].split('/').map{|c| c.camelize }.join('::') }

        classes = constant_parts.map do |cp|
          "Aviator::#{ provider_name.camelize }::#{ service_name.camelize }::#{ cp }".constantize
        end

        service.request_classes.must_equal classes
      end

    end


    describe '#default_session_data=' do

      it 'sets the service\'s default session data' do
        bootstrap = {
          :auth_service => {
            :name     => 'identity',
            :host_uri => 'http://devstack:5000/v2.0',
            :request  => 'create_token'
          }
        }

        svc = service(bootstrap)

        session_data_1 = svc.default_session_data
        session_data_2 = do_auth_request

        svc.default_session_data = session_data_2

        svc.default_session_data.wont_equal session_data_1
        svc.default_session_data.must_equal session_data_2
      end

    end

  end

end
