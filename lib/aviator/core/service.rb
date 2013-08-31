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


    class Logger < Faraday::Response::Logger      
      def initialize(app, logger=nil)
        super(app)
        @logger = logger || begin
          require 'logger'
          ::Logger.new(self.class::LOG_FILE_PATH)
        end
      end
    end

    # Because we define requests in a flattened scope, we want to make sure that when each
    # request is initialized it doesn't get polluted by instance variables and methods
    # of the containing class. This builder class makes that happen by being a
    # scope gate for the file. See Metaprogramming Ruby, specifically on blocks and scope
    # class RequestBuilder
    # 
    #   # This method gets called by the request file eval'd in self.build below
    #   def define_request(request_name, &block)
    #     klass = Class.new(Aviator::Request, &block)
    #     return klass, request_name
    #   end
    # 
    # 
    #   def self.build(path_to_request_file)
    #     # clean_room = new
    #     # clean_room.instance_eval(File.read(path_to_request_file))
    #     Kernel.load(path_to_request_file, true)
    #   end
    # 
    # 
    #   private_class_method :new
    # 
    # end

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

      request_class = find_request(request_name, session_data, options[:endpoint_type])

      raise UnknownRequestError.new(request_name) unless request_class

      request  = request_class.new(session_data, &params)

      response = http_connection.send(request.http_method) do |r|
        r.url        request.url
        r.headers.merge!(request.headers)        if request.headers?
        r.query    = request.querystring         if request.querystring?
        r.body     = JSON.generate(request.body) if request.body?
      end

      Aviator::Response.send(:new, response, request)
    end


    def requests
      @requests
    end
    
    
    private


    def http_connection
      @http_connection ||= Faraday.new do |conn|
        if log_file
          # Ugly hack to make logger configurable
          const_name = 'LOG_FILE_PATH'
          Logger.send(:remove_const, const_name) if Logger.const_defined?(const_name)
          Logger.const_set(const_name, log_file)
          conn.use     Logger.dup
        end
        conn.adapter Faraday.default_adapter
        conn.headers['Content-Type'] = 'application/json'
      end
    end


    # Candidate for extraction to aviator/openstack
    def find_request(name, session_data, endpoint_type=nil)
      endpoint_types = if endpoint_type
                         [endpoint_type.to_s.camelize]
                       else
                         ['Public', 'Admin']
                       end

      namespace = Aviator.const_get(provider.camelize)
                         .const_get(service.camelize)   

      version = infer_version(session_data).to_s.camelize
            
      return nil unless version && namespace.const_defined?(version)

      namespace = namespace.const_get(version)

      endpoint_types.each do |endpoint_type|
        name = name.to_s.camelize
        
        next unless namespace.const_defined?(endpoint_type)
        next unless namespace.const_get(endpoint_type).const_defined?(name)
        
        return namespace.const_get(endpoint_type).const_get(name)
      end

      nil
    end


    # Candidate for extraction to aviator/openstack
    def infer_version(session_data)
      if session_data.has_key?(:auth_service) && session_data[:auth_service][:api_version]
        session_data[:auth_service][:api_version].to_sym

      elsif session_data.has_key?(:auth_service) && session_data[:auth_service][:host_uri]
        m = session_data[:auth_service][:host_uri].match(/(v\d+)\.?\d*/)
        return m[1].to_sym unless m.nil?

      elsif session_data.has_key? :access
        service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service }
        service_spec[:endpoints][0][:publicURL].match(/(v\d+)\.?\d*/)[1].to_sym
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

      request_file_paths.each{ |path| Kernel.load(path, true) }
    end
    
    
    def log_file
      @log_file
    end
    
  end

end