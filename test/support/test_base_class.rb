module Aviator
class Test < MiniTest::Spec

  def self.validate_attr(name, extra_desc=nil, &block)
    it "returns the correct value for #{ name.to_s } #{ extra_desc }", &block
  end


  def self.validate_response(scenario, &block)
    it "leads to a valid response when #{ scenario.to_s }", &block
  end


  def cassette_name
    path = self.class.to_s \
             .gsub(/^aviator\//, '') \
             .gsub(/^Aviator::Test::/, '') \
             .gsub(/::#/,  '/i_') \
             .gsub(/::::/, '/c_') \
             .gsub(/::/,   '/')

    path = Aviator::StrUtil.underscore(path)

    basename = __name__.gsub(/test_\d+_/, '')

    "#{ path }/#{ basename }"
  end


  before do
    ::VCR.insert_cassette cassette_name
  end


  after do
    ::VCR.eject_cassette
  end

end
end
