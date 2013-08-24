module Aviator

  class Service

    class AccessDetailsNotDefinedError < StandardError
      def initialize
        super ":access_details is not defined."
      end
    end


    class ServiceNameNotDefinedError < StandardError
      def initialize
        super ":service_name is not defined."
      end
    end


    class UnknownRequestError < StandardError
      def initialize(request_name)
        super "Unknown request #{ request_name }."
      end
    end


    # Because we define requests in a flattened scope, we want to make sure that when each
    # request is initialized it doesn't get polluted by instance variables and methods
    # of the containing class. This builder class makes that happen by being a
    # scope gate for the file.
    class RequestBuilder
    
      def define_request(request_name, &block)
        klass = Class.new(Aviator::Request, &block)
        return request_name, klass
      end
    

      def self.build(path_to_request_file)
        clean_room = self.new
        clean_room.instance_eval(File.read(path_to_request_file))
      end

    end



    attr_reader :service_name,
                :access_details


    def initialize(opts={})
      @service_name   = opts[:service_name]
      @access_details = opts[:access_details]

      raise ServiceNameNotDefinedError.new if service_name.nil?
      raise AccessDetailsNotDefinedError.new if access_details.nil?

      load_requests
      initialize_http_connection
    end


    def request(request_name)
      params = {}
      yield params

      request_class = find_request(request_name)

      raise UnknownRequestError.new(request_name) if request_class.nil?

      request = request_class.new(params)

      http_connection.headers['X-Auth-Token'] = token unless request.anonymous?

      result = http_connection.send(request.http_method) do |r|
        r.url request.path

        r.query = request.querystring if request.querystring?
        r.body  = JSON.generate(request.body) if request.body?
      end

      result
    end


    private


    def http_connection
      @http_connection
    end

    
    def find_request(name)
      version = infer_version(http_connection.url_prefix)
      
      return nil unless requests[version]
      
      [:public, :admin].each do |endpoint_type|
        next unless requests[version][endpoint_type]
        pair = requests[version][endpoint_type].find{ |k, v| k == name }
        return pair[1] unless pair.nil?
      end
      
      nil
    end


    def infer_version(url)
      url.path.match(/(v\d+)\.?\d*/)[1].to_sym
    end


    def initialize_http_connection
      @http_connection = Faraday.new do |conn|
        conn.url_prefix = access_details[:bootstrap][:url] if access_details[:bootstrap]
        # conn.use     Aviation::Logger
        conn.adapter Faraday.default_adapter
        conn.headers['Content-Type'] = 'application/json'
      end
    end


    def load_requests
      request_file_paths = Dir.glob(Pathname.new(__FILE__).join(
                             '..', 
                             '..', 
                             'openstack', 
                             service_name.to_s, 
                             '**', 
                             '*.rb'
                             ).expand_path
                           )

      @requests ||= {}

      request_file_paths.each do |path_to_file|
        request_name, klass = RequestBuilder.build(path_to_file)
        key = "#{ klass.api_version }/#{ klass.endpoint_type }/#{ request_name }"
        
        api_version   = @requests[klass.api_version] ||= {}
        endpoint_type = api_version[klass.endpoint_type] ||= {}
        endpoint_type[request_name] = klass
      end
    end


    def requests
      @requests
    end

  end

end