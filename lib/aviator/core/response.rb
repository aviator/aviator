module Aviator

  class Response
    extend Forwardable

    def_delegators :@response, :status

    attr_reader :request

    def initialize(response, request)
      @response = response
      @request  = request
    end


    def body
      @body ||= if raw_body.length > 0
        if Aviator::Compatibility::RUBY_1_8_MODE
          clean_body = raw_body.gsub(/\\ /, ' ')
        else
          clean_body = raw_body
        end

        Hashish.new(JSON.parse(clean_body))
      else
        Hashish.new({})
      end
    end


    def headers
      @headers ||= Hashish.new(@response.headers)
    end


    def to_hash
      Hashish.new({
        :status  => status,
        :headers => headers,
        :body    => body
      })
    end

    private

    def raw_body
      @raw_body ||= @response.body
    end

  end

end
