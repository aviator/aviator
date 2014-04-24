module Aviator

  class Service

    class AccessDetailsNotDefinedError < StandardError
      def initialize
        super ":access_details is not defined."
      end
    end

    class ProviderNotDefinedError < StandardError
      def initialize
        super ":provider is not defined."
      end
    end

    class ServiceNameNotDefinedError < StandardError
      def initialize
        super ":service is not defined."
      end
    end

    class SessionDataNotProvidedError < StandardError
      def initialize
        super "default_session_data is not initialized and no session data was "\
              "provided in the method call."
      end
    end


    class UnknownRequestError < StandardError
      def initialize(request_name)
        super "Unknown request #{ request_name }."
      end
    end


    class MissingServiceEndpointError < StandardError
      def initialize(service_name, request_name)
        request_name = request_name.to_s.split('::').last.underscore
        super "The session's service catalog does not have an entry for the #{ service_name } "\
              "service. Therefore, I don't know to which base URL the request should be sent. "\
              "This may be because you are using a default or unscoped token. If this is not your "\
              "intention, please authenticate with a scoped token. If using a default token is your "\
              "intention, make sure to provide a base url when you call the request. For example: \n\n"\
              "session.#{ service_name }_service.request :#{ request_name }, base_url: 'http://myenv.com:9999/v2.0' do |params|\n"\
              "  params[:example1] = 'example1'\n"\
              "  params[:example2] = 'example2'\n"\
              "end\n\n"
      end
    end

    attr_accessor :default_session_data

    attr_reader :service,
                :provider


    def initialize(opts={})
      @provider = opts[:provider] || (raise ProviderNotDefinedError.new)
      @service  = opts[:service]  || (raise ServiceNameNotDefinedError.new)
      @log_file = opts[:log_file]

      @default_session_data = opts[:default_session_data]

      load_requests
    end


    def request(request_name, options={}, &params)
      session_data = options[:session_data] || default_session_data

      raise SessionDataNotProvidedError.new unless session_data
      [:base_url].each do |k|
        session_data[k] = options[k] if options[k]
      end

      request_class = find_request(request_name, session_data, options[:endpoint_type], options[:api_version])
      #binding.pry
      raise UnknownRequestError.new(request_name) unless request_class

      request  = request_class.new(session_data, &params)
      #binding.pry
      response = http_connection.send(request.http_method) do |r|
        r.url        request.url
        r.headers.merge!(request.headers)        if request.headers?
        r.query    = request.querystring         if request.querystring?
        r.body     = JSON.generate(request.body) if request.body? && !request.body.empty?
      end
      #binding.pry


      Aviator::Response.send(:new, response, request)
    end


    def request_classes
      @request_classes
    end


    private


    def http_connection
      @http_connection ||= Faraday.new do |conn|
        conn.use     Logger.configure(log_file) if log_file
        conn.adapter Faraday.default_adapter

        conn.headers['Content-Type'] = 'application/json'
      end
    end


    # Candidate for extraction to aviator/openstack
    def find_request(name, session_data, endpoint_type=nil, api_version = nil)
      endpoint_types = if endpoint_type
                         [endpoint_type.to_s.camelize]
                       else
                         ['Public', 'Admin']
                       end

      base_namespace = Aviator.const_get(provider.camelize)
                         .const_get(service.camelize)
      # binding.pry
      chosen_version = (api_version ? api_version.to_s.camelize : nil)
      inferred_version = infer_version(session_data, name).to_sym
      #binding.pry

      #if the version has been passed, use that,
      #otherwise, see if the inferred version has it and use that,
      #else, use any other that supports it
      versions = if chosen_version
        [chosen_version]
      else
        [inferred_version, :v3, :v2, :v1]
      end

      versions.each do |version|
        version_name = version.to_s.camelize
        next unless base_namespace.const_defined?(version_name)
        namespace = base_namespace.const_get(version_name, name)

        endpoint_types.each do |endpoint_type|
          name = name.to_s.camelize
          #binding.pry
          next unless namespace.const_defined?(endpoint_type)
          next unless namespace.const_get(endpoint_type).const_defined?(name)

          return namespace.const_get(endpoint_type).const_get(name)
        end
      end

      nil
    end


    # Candidate for extraction to aviator/openstack
    def infer_version(session_data, request_name='sample_request')
      if session_data.has_key?(:auth_service) && session_data[:auth_service][:api_version]
        session_data[:auth_service][:api_version].to_sym

      elsif session_data.has_key?(:auth_service) && session_data[:auth_service][:host_uri]
        m = session_data[:auth_service][:host_uri].match(/(v\d+)\.?\d*/)
        return m[1].to_sym unless m.nil?

      elsif session_data.has_key? :base_url
        m = session_data[:base_url].match(/(v\d+)\.?\d*/)
        return m[1].to_sym unless m.nil?
      elsif session_data.catalog
        api_version = 'v2'
        service_with_version = session_data.catalog.find { |s| s[:type] == ("%s%s" % [service, api_version]) }
        return api_version if service_with_version

        service_spec = session_data.catalog.find { |s| s[:type] == service.to_s }
        raise MissingServiceEndpointError.new(service.to_s, request_name) unless service_spec
        url = service_spec[:endpoints].find{|a| a[:interface] == 'public'}["url"]
        version_from_url(url)
      end
    end

    def load_requests
      # TODO: This should be determined by a provider-specific module.
      # e.g. Aviator::OpenStack::requests_base_dir
      request_file_paths = Dir.glob(Pathname.new(__FILE__).join(
                             '..',
                             '..',
                             provider.to_s,
                             service.to_s,
                             '**',
                             '*.rb'
                             ).expand_path
                           )

      request_file_paths.each{ |path| require path }

      constant_parts = request_file_paths
                        .map{|rf| rf.to_s.match(/#{provider}\/#{service}\/([\w\/]+)\.rb$/) }
                        .map{|rf| rf[1].split('/').map{|c| c.camelize }.join('::') }

      @request_classes = constant_parts.map do |cp|
        "Aviator::#{provider.camelize}::#{service.camelize}::#{cp}".constantize
      end
    end

    def log_file
      @log_file
    end

    private

     def version_from_url(url)
       version = url.match(/(v\d+)\.?\d*/)
       version ? version[1].to_sym : :v1
     end

  end

end
