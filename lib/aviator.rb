# Add the parent dir to the load path. This is for when
# Aviator is not installed as a gem
lib_path = File.dirname(__FILE__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include? lib_path

require 'aviator/core'
require "aviator/openstack/provider"
