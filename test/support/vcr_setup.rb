require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = Pathname.new(__FILE__).join('..', '..', 'cassettes')
  c.hook_into :faraday

  unless @vcr_port_matcher_registered
    # References:
    #   From VCR docs: http://goo.gl/j0fiJ
    #   Discussion by author: http://goo.gl/p9q4r
    c.register_request_matcher :port do |r1, r2|
      r1.parsed_uri.port == r2.parsed_uri.port
    end
    @vcr_port_matcher_registered = true
  end


  c.default_cassette_options = {
    # If no cassette exists for a spec, VCR will record. Afterwards, VCR will
    # stop recording for that spec. If new requests are made that are not
    # matched by anything in the cassette, an error is thrown
    record: :once,

    match_requests_on: [:method, :port, :path, :query, :headers, :body],

    # Strict mocking
    # Inspired by: http://myronmars.to/n/dev-blog/2012/06/thoughts-on-mocking
    allow_unused_http_interactions: false,

    # Enable ERB in the cassettes.
    # Reference: http://goo.gl/aPXYk
    erb: true
  }
end