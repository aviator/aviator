require 'test_helper'

class Aviator::Test

  describe 'aviator/core/cli/describer' do

    def build_request(provider_name, service_name, request_name, &block)
      base_name = :sample_base
      base_ver  = :v999
      base_ept  = :public

      unless @base
        request_path = [provider_name, service_name, :requests, base_ver, base_ept, base_name]

        @base = request_path.inject(Aviator) do |namespace, sym|
          const_name = Aviator::StrUtil.camelize(sym.to_s)

          if namespace && namespace.const_defined?(const_name, false)
            namespace.const_get(const_name, false)
          else
            nil
          end
        end

        @base ||= Aviator.define_request base_name do
                    meta :provider,      provider_name
                    meta :service,       service_name
                    meta :api_version,   base_ver
                    meta :endpoint_type, base_ept
                  end
      end

      inherit = [provider_name.to_sym, service_name.to_sym, base_ver, base_ept, base_name]

      Aviator.define_request request_name, :inherit => inherit, &block
    end


    def klass
      Aviator::Describer
    end

    def provider_names
      klass.send(:provider_names)
    end


    def request_classes(provider_name, service_name)
      klass.send(:request_classes, provider_name, service_name)
    end


    def service_names(provider_name)
      klass.send(:service_names, provider_names.first)
    end


    describe '::describe_aviator' do

      it 'shows a list of providers' do
        expected = "Available providers:\n"
        expected << provider_names.map{|p| "  #{ p }" }.join("\n") + "\n"

        klass.describe_aviator.must_equal expected
      end

    end # describe '::describe_aviator'


    describe '::describe_provider' do

      it 'shows a list of available provider services' do
        provider = provider_names.first

        expected = "Available services for #{ provider }:\n"
        expected << service_names(provider).map{|s| "  #{ s }" }.join("\n") + "\n"

        klass.describe_provider(provider).must_equal expected
      end

    end # describe '::describe_provider'


    describe '::describe_service' do

      it 'shows a list of available service requests' do
        provider = provider_names.first
        service  = service_names(provider).first
        requests = request_classes(provider, service)

        expected  = "Available requests for #{ provider } #{ service }_service:\n"

        requests.each do |klass|
          expected << "  #{ klass.api_version } #{ klass.endpoint_type } #{ Aviator::StrUtil.underscore(klass.name.split('::').last) }\n"
        end

        klass.describe_service(provider, service).must_equal expected
      end

    end # describe '::describe_service'


    describe '::describe_request' do

      it 'shows the request name and sample code' do
        provider     = provider_names.first
        service      = service_names(provider).first
        request_name = 'sample_request1'

        request_class = build_request(provider, service, request_name)

        expected = <<-EOF
Request: #{ request_name }

Sample Code:
  session.request(:#{ service }_service, :#{ request_name })
EOF

        output = klass.describe_request(
          provider,
          service,
          request_class.api_version.to_s,
          request_class.endpoint_type.to_s,
          request_name.to_s
        )

        output.must_equal expected
      end


      it "shows parameters when provided" do
        provider     = provider_names.first
        service      = service_names(provider).first
        request_name = 'sample_request2'

        request_class = build_request(provider, service, request_name) do
                          param :theParam, :required => true
                          param :another, :required => false
                        end

        expected = <<-EOF
Request: #{ request_name }

Parameters:
 +----------+-----------+
 | NAME     | REQUIRED? |
 +----------+-----------+
 | another  |     N     |
 | theParam |     Y     |
 +----------+-----------+

Sample Code:
  session.request(:#{ service }_service, :#{ request_name }) do |params|
    params.another = value
    params.theParam = value
  end
EOF

        output = klass.describe_request(
          provider,
          service,
          request_class.api_version.to_s,
          request_class.endpoint_type.to_s,
          request_name.to_s
        )

        output.must_equal expected
      end


      it "display aliases when available" do
        provider     = provider_names.first
        service      = service_names(provider).first
        request_name = 'sample_request3'

        request_class = build_request(provider, service, request_name) do
                          param :theParam, :required => true, :alias => :the_param
                          param :anotherParam, :required => false, :alias => :another_param
                        end

        expected = <<-EOF
Request: #{ request_name }

Parameters:
 +--------------+-----------+---------------+
 | NAME         | REQUIRED? | ALIAS         |
 +--------------+-----------+---------------+
 | anotherParam |     N     | another_param |
 | theParam     |     Y     | the_param     |
 +--------------+-----------+---------------+

Sample Code:
  session.request(:#{ service }_service, :#{ request_name }) do |params|
    params.another_param = value
    params.the_param = value
  end
EOF

        output = klass.describe_request(
          provider,
          service,
          request_class.api_version.to_s,
          request_class.endpoint_type.to_s,
          request_name.to_s
        )

        output.must_equal expected
      end


      it "display links when available" do
        provider     = provider_names.first
        service      = service_names(provider).first
        request_name = 'sample_request4'

        request_class = build_request(provider, service, request_name) do
                          param :theParam, :required => true, :alias => :the_param
                          param :anotherParam, :required => false, :alias => :another_param

                          link 'link1', 'http://www.link.com'
                        end

        expected = <<-EOF
Request: #{ request_name }

Parameters:
 +--------------+-----------+---------------+
 | NAME         | REQUIRED? | ALIAS         |
 +--------------+-----------+---------------+
 | anotherParam |     N     | another_param |
 | theParam     |     Y     | the_param     |
 +--------------+-----------+---------------+

Sample Code:
  session.request(:#{ service }_service, :#{ request_name }) do |params|
    params.another_param = value
    params.the_param = value
  end

Links:
  link1:
    http://www.link.com
EOF

        output = klass.describe_request(
          provider,
          service,
          request_class.api_version.to_s,
          request_class.endpoint_type.to_s,
          request_name.to_s
        )

        output.must_equal expected
      end


    end # describe '::describe_request'


  end # describe 'aviator/core/cli/describe'

end # class Aviator::Test
