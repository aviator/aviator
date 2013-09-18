require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = Pathname.new(__FILE__).join('..', '..', 'cassettes')
  c.debug_logger = File.open(Pathname.new(__FILE__).join('..', '..', '..', 'tmp', 'vcr.log'), 'w')
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

  #=========== BEGIN FILTERS FOR SENSITIVE DATA ===========

  configs = [:openstack_admin, :openstack_member]
  env     = Aviator::Test::Environment

  [:username, :password, :tenantName].each do |key|
    configs.each do |config|
      c.filter_sensitive_data("<#{ config.to_s.upcase }_#{key.to_s.upcase}>") { env.send(config)[:auth_credentials][key]  }
    end
  end

  configs.each do |config|

    c.filter_sensitive_data("<#{ config.to_s.upcase }_HOST_URI>") do
      auth_url = URI(env.send(config)[:auth_service][:host_uri])
      auth_url.scheme + '://' + auth_url.host
     end

    # In a multi-host environment, this will come in handy since HOST_URI wont match the
    # URI of services or resources available in a different host but same domain.
    c.filter_sensitive_data("<#{ config.to_s.upcase }_ENV_DOMAIN>") do
      domain_patterns = Regexp.union([
        /\.[\w-]+\.[^\.]+\.\w{2,3}$/,
        /\.[^\.]+\.\w{2,3}$/,
        /\.[^\.]+\.\w{2,3}.\w+$/,
        /^\w+$/
      ])

      auth_url = URI(env.send(config)[:auth_service][:host_uri])
      auth_url.host.match(domain_patterns)
    end

  end

  #=========== END FILTERS FOR SENSITIVE DATA ===========

  c.default_cassette_options = {
    # IF NOT RUNNING IN CI:
    #   If no cassette exists for a spec, VCR will record. Afterwards, VCR will
    #   stop recording for that spec. If new requests are made that are not
    #   matched by anything in the cassette, an error is thrown
    #
    # IF RUNNING IN CI:
    # Test should immediately throw an error if no cassette exists for a 
    # given example that needs one.
    record: (ENV['CI'] || ENV['TRAVIS'] ? :none : :once),

    match_requests_on: [:method, :port, :path, :query, :headers, :body],

    # Strict mocking
    # Inspired by: http://myronmars.to/n/dev-blog/2012/06/thoughts-on-mocking
    allow_unused_http_interactions: false,

    # Enable ERB in the cassettes.
    # Reference: http://goo.gl/aPXYk
    erb: true
  }
end
