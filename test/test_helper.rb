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
  
  add_group 'Core', 'lib/aviator/core'
  add_group 'OpenStack', 'lib/aviator/openstack'
end

require 'minitest/autorun'

# Do not require these gems when running in the CI
unless ENV['CI'] || ENV['TRAVIS']
  require 'pry'
end

# Clean the tmp dir of log files
Dir[Pathname.new(__FILE__).expand_path.join('..', '..', 'tmp', '*.log')].each { |f| File.delete(f) }

# Make sure this loads first
require Pathname.new(__FILE__).join('..', 'support', 'test_base_class.rb').expand_path

# Load all helpers in test/support
Dir[Pathname.new(__FILE__).join('..', 'support', '*.rb')].each do |f|
  require f
end

require 'aviator/core'

at_exit do
  # Load all requests so that they are reported by SimpleCov
  request_file_paths = Dir.glob(Pathname.new(__FILE__).join(
                         '..', '..', 'lib', 'aviator',
                         'openstack', '**', '*.rb'
                         ).expand_path
                       )

  request_file_paths.each do |path| 
    # Ignore the load errors since all we want is for
    # SimpleCov to detect the request file.
    begin
      Kernel.load(path, true)
    rescue e; end
  end
end