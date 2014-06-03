# Add the gem's lib folder to the load path
$:.unshift File.expand_path('../../lib', __FILE__)


# Set-up coverage reporting (local and Coveralls.com)
require 'simplecov'
require 'coveralls'
SimpleCov.command_name 'MiniTest'
SimpleCov.formatter = if ENV['TRAVIS']
                        SimpleCov::Formatter::MultiFormatter[
                          SimpleCov::Formatter::HTMLFormatter,
                          Coveralls::SimpleCov::Formatter
                        ]
                      else
                        SimpleCov::Formatter::HTMLFormatter
                      end

SimpleCov.start do
  add_filter '/test/'
  add_filter '/.bundled_gems/'
  
  add_group 'Core', 'lib/aviator/core'
  add_group 'OpenStack', 'lib/aviator/openstack'
end

require 'minitest/autorun'

# May be used by other test helpers under test/support
def running_in_ci
  ['BUILD_NUMBER', 'CI', 'JENKINS_URL'].any? { |name| ENV.key? name }
end

unless running_in_ci
  require 'pry'
end

# Clean the tmp dir of log files
Dir[Pathname.new(__FILE__).expand_path.join('..', '..', 'tmp', '*.log')].each { |f| File.delete(f) }

# Make sure these files are loaded before the others since there are some CI workers
# in Travis CI that seem to load files in the iterator below in a random way.
require Pathname.new(__FILE__).join('..', 'support', 'test_base_class.rb').expand_path
require Pathname.new(__FILE__).join('..', 'support', 'test_environment.rb').expand_path

# Load all helpers in test/support
Dir[Pathname.new(__FILE__).join('..', 'support', '*.rb')].each do |f|
  require f
end

require 'aviator'
require 'aviator/core/cli'
