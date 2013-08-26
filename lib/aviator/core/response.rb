module Aviator

  class Response
    
    
    def method_missing(name, *args)
      case name
      when :body, :headers, :status
        response.send(name)
      when :request
        request
      else
        super(name, *args)
      end
    end
    
    
    private
    
    attr_reader :response,
                :request
    
    def initialize(response, request)
      @response = response
      @request  = request
    end
    
  end
  
end