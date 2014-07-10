module Aviator
module Openstack

  module Provider

    class << self

      def find_request(service, name, session_data, options)
        service = service.to_s
        endpoint_type = options[:endpoint_type]
        endpoint_types = if endpoint_type
                           [endpoint_type.to_s.camelize]
                         else
                           ['Public', 'Admin']
                         end

        namespace = Aviator.const_get('Openstack') \
                           .const_get(service.camelize) \
                           .const_get('Requests')

        if options[:api_version]
          m = options[:api_version].to_s.match(/(v\d+)\.?\d*/)
          version = m[1].to_s.camelize unless m.nil?
        end

        version ||= infer_version(session_data, name, service).to_s.camelize

        return nil unless version && namespace.const_defined?(version)

        namespace = namespace.const_get(version, name)

        endpoint_types.each do |endpoint_type|
          name = name.to_s.camelize

          next unless namespace.const_defined?(endpoint_type)
          next unless namespace.const_get(endpoint_type).const_defined?(name)

          return namespace.const_get(endpoint_type).const_get(name)
        end

        nil
      end


      def root_dir
        Pathname.new(__FILE__).join('..').expand_path
      end


      def request_file_paths(service)
          Dir.glob(Pathname.new(__FILE__).join(
            '..',
             service.to_s,
            'requests',
            '**',
            '*.rb'
            ).expand_path
          )
      end


      private

      def infer_version(session_data, request_name, service)
        if session_data.has_key?(:auth_service) && session_data[:auth_service][:api_version]
        session_data[:auth_service][:api_version].to_sym

        elsif session_data.has_key?(:auth_service) && session_data[:auth_service][:host_uri]
          m = session_data[:auth_service][:host_uri].match(/(v\d+)\.?\d*/)
          return m[1].to_sym unless m.nil?

        elsif session_data.has_key? :base_url
          m = session_data[:base_url].match(/(v\d+)\.?\d*/)
          return m[1].to_sym unless m.nil?

        elsif session_data.has_key? :access
          service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service }
          raise Aviator::Service::MissingServiceEndpointError.new(service.to_s, request_name) unless service_spec
          version = service_spec[:endpoints][0][:publicURL].match(/(v\d+)\.?\d*/)
          version ? version[1].to_sym : :v1
        end
      end

    end # class << self

  end # module Provider

end # module Openstack
end # module Aviator
