module Aviator

  class Response
    extend Forwardable

    def_delegators :@response, :headers, :status

    attr_reader :request

    def initialize(response, request)
      @response = response
      @request  = request
    end


    def body
      mash(raw_body.length > 0 ? JSON.parse(raw_body) : {} )
    end

    def headers
      mash(raw_headers)
    end


    private

    def raw_body
      @response.body
    end

    def mash(*args)
      Hashie::Mash.new(*args)
    end

    def raw_headers
      @response.headers
    end

  end

end