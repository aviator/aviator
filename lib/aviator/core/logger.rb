module Aviator

  class Logger < Faraday::Response::Middleware
    extend Forwardable

    def initialize(app, logger=nil)
      super(app)
      @logger = logger || begin
        require 'logger'
        ::Logger.new(self.class::LOG_FILE_PATH)
      end
    end


    def_delegators :@logger, :debug, :info, :warn, :error, :fatal


    def call(env)
      info(env[:method].to_s.upcase) { env[:url].to_s }
      debug('REQ_HEAD') { dump_headers env[:request_headers] }
      debug('REQ_BODY') { dump_body env[:body] }
      super
    end


    def on_complete(env)
      info('STATUS') { env[:status].to_s }
      debug('RES_HEAD') { dump_headers env[:response_headers] }
      debug('RES_BODY') { dump_body env[:body] }
    end


    def self.configure(log_file_path)
      # Return a subclass with its logfile path set. This
      # must be done so that different sessions can log to
      # different paths.
      Class.new(self) { const_set('LOG_FILE_PATH', log_file_path) }
    end


    private

    def dump_body(body)
      return if body.nil?

      # :TODO => Make this configurable
      body.gsub(/["']password["']:["']\w*["']/, '"password":[FILTERED_VALUE]')
    end

    def dump_headers(headers)
      headers.map { |k, v| "#{k}: #{v.inspect}" }.join("; ")
    end
  end

end
