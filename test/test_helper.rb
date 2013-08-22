# Add the gem's lib folder to the load path
$:.unshift File.expand_path('../../lib', __FILE__)


# Set-up coverage reporting (local and Coveralls.com)
require 'simplecov'
require 'coveralls'
SimpleCov.command_name 'MiniTest'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/autorun'

# Do not require these gems when running in the CI
unless ENV['CI'] || ENV['TRAVIS']
  require 'pry'
end

# Load all helpers in test/support
Dir[Pathname.new(__FILE__).join('..', 'support', '*.rb')].each do |f|
  require f
end

require 'aviator'
