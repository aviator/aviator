module Aviator
class Test < MiniTest::Spec

    def cassette_name
      path = self.class.to_s
               .gsub(/^Aviator::Test::/, '')
               .gsub(/::#/,  '/i_')
               .gsub(/::::/, '/c_')
               .gsub(/::/,   '/')
               .underscore
                 
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