module Aviator

  #
  # Manages a service
  #
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
      def initialize(service_name, request_name)
        super "\n\nERROR: default_session_data is not initialized and no session data was provided in\n"\
              "the method call. You have two ways to fix this:\n\n"\
              "   1) Call Session#authenticate before calling Session##{service_name}_service, or\n\n"\
              "   2) If you're really sure you don't want to authenticate beforehand,\n"\
              "      construct the method call this way:\n\n"\
              "          service = session.#{service_name}_service\n"\
              "          service.request :#{request_name}, :api_version => :v2, :session_data => sessiondatavar\n\n"\
              "      Replace :v2 with whatever available version you want to use and make sure sessiondatavar\n"\
              "      is a hash that contains, at least, the :base_url key. Other keys, such as :service_token may\n"\
              "      be needed depending on what the request class you are calling requires.\n\n"
      end
    end

    class UnknownRequestError < StandardError
      def initialize(request_name, options)
        super "Unknown request #{ request_name } #{ options }."
      end
    end


    class MissingServiceEndpointError < StandardError
      def initialize(service_name, request_name)
        request_name = request_name.to_s.split('::').last.underscore
        super "The session's service catalog does not have an entry for the #{ service_name } "\
              "service. Therefore, I don't know to which base URL the request should be sent. "\
              "This may be because you are using a default or unscoped token. If this is not your "\
              "intention, please authenticate with a scoped token. If using a default token is your "\
              "intention, make sure to provide a base url when you call the request. For :example => \n\n"\
              "session.#{ service_name }_service.request :#{ request_name }, :base_url => 'http://myenv.com:9999/v2.0' do |params|\n"\
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
      @default_options = opts[:default_options] || {}

      @default_session_data = opts[:default_session_data]

      load_requests
    end

    #
    # No longer recommended for public use. Use Aviator::Session#request instead
    #
    def request(request_name, options={}, &params)
      if options[:api_version].nil? && @default_options[:api_version]
        options[:api_version] = @default_options[:api_version]
      end

      session_data = options[:session_data] || default_session_data

      raise SessionDataNotProvidedError.new(@service, request_name) unless session_data

      [:base_url].each do |k|
        session_data[k] = options[k] if options[k]
      end

      request_class = provider_module.find_request(service, request_name, session_data, options)

      raise UnknownRequestError.new(request_name, options) unless request_class

      # Always use :params over &params if provided
      if options[:params]
        params = lambda do |params|
          options[:params].each do |key, value|
            begin
              params[key] = value
            rescue NameError => e
              raise NameError.new("Unknown param name '#{key}'")
            end
          end
        end
      end

      request  = request_class.new(session_data, &params)

      response = http_connection.send(request.http_method) do |r|
        r.url        request.url
        r.headers.merge!(request.headers)        if request.headers?
        r.query    = request.querystring         if request.querystring?
        r.body     = JSON.generate(request.body) if request.body?
      end

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


    def load_requests
      request_file_paths = provider_module.request_file_paths(service)
      request_file_paths.each{ |path| require path }

      constant_parts = request_file_paths \
                        .map{|rf| rf.to_s.match(/#{provider}\/#{service}\/([\w\/]+)\.rb$/) } \
                        .map{|rf| rf[1].split('/').map{|c| c.camelize }.join('::') }

      @request_classes = constant_parts.map do |cp|
        "Aviator::#{provider.camelize}::#{service.camelize}::#{cp}".constantize
      end
    end


    def log_file
      @log_file
    end


    def provider_module
      @provider_module ||= "Aviator::#{provider.camelize}::Provider".constantize
    end

  end

end
