require "bundler/gem_tasks"
require "rake/testtask"
 
Rake::TestTask.new(:test) do |t|
  t.pattern = "test/aviator/**/*_test.rb"
  t.libs.push 'test'
end
 
task :default => :test