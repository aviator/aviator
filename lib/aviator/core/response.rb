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
      if raw_body.length > 0
        JSON.parse(raw_body).with_indifferent_access
      else
        {}
      end
    end
    
    
    private
    
    def raw_body
      @response.body
    end
    
  end
  
end