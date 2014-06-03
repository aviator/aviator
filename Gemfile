source 'https://rubygems.org'

# Specify your gem's dependencies in aviator.gemspec
gemspec

# Putting these gems in the test group so that
# we can tell travis-ci not to build any of the
# development gems. Makes the build run faster.
group :test do
  if Aviator::Compatibility::RUBY_1_8_MODE
    gem 'mime-types', '~> 1.25.1'
  end

  gem 'rake'
  gem 'simplecov', '~> 0.7.0'
  gem 'coveralls', '~> 0.7.0'
  gem 'json', '~> 1.7.0'
  gem 'minitest', '~> 4.7.0'
  gem 'minitest-reporters', '~> 0.14.20'
  gem 'vcr', '~> 2.8.0'
end
