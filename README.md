# Aviator

A lightweight library for communicating with the OpenStack API.


## Installation

Add this line to your application's Gemfile:

    gem 'aviator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aviator

## Usage

```ruby
require 'aviator'

# Create a new session. See 'Configuration' below for the config file format.
session = Aviator::Session.new(
            config_file: 'path/to/aviator.yml',
            environment: :production,
            log_file:    'path/to/aviator.log'
          )

# Authenticate against the auth service specified in :config_file. If no 
# credentials are available in the config file, this line will throw an error.
session.authenticate

# You can re-authenticate anytime. Note that this creates a new token in the 
# underlying environment while the old token is discarded by the Session object.
# Be aware of this fact as it might unnecessarily generate too many tokens.
#
# Notice how you can override the credentials in the config file! Also note that
# the keys used below (:username, :password, :tenantName) match the name as 
# indicated in the official OpenStack documentation.
session.authenticate do |credentials|
  credentials[:username]   = myusername
  credentials[:password]   = mypassword
  credentials[:tenantName] = tenantName
end

# Serialize the session information for caching
json_str = session.to_json

# Reload the session information. This does not create a new token.
session = Aviator::Session.load(json_str)

# Get a handle to the Identity Service using the token in the default key
keystone = session.identity_service

# Create a new tenant
response = keystone.request(:create_tenant) do |params|
  params[:name]        = 'Project'
  params[:description] = 'My Project'
  params[:enabled]     = true
end

# Aviator uses parameter names as defined in the official OpenStack API doc. You can 
# also access the params via dot notation (e.g. params.description) or by using a string
# for a hash key (e.g. params['description']). However, keep in mind that OpenStack
# parameters that have dashes and other characters that are not valid for method names
# and symbols must be expressed as strings. E.g. params['changes-since']


# Be explicit about the endpoint type. Useful in those rare instances when
# the same request name means differently depending on the endpoint type.
# For example, in OpenStack, :list_tenants will return only the tenants the
# user is a member of in the public endpoint whereas the admin endpoint will
# return all tenants in the system.
response = keystone.request(:list_tenants, endpoint_type: 'admin')
```

## Configuration

The configuration file is a simple YAML file with one or more environment definitions.

```
production:
  provider: openstack
  auth_service:
    name:        identity
    host_uri:    http://my.openstackenv.org:5000
    request:     create_token
    api_version: v2             # Optional if version is indicated in host_uri
  auth_credentials:
    username:   admin
    password:   mypassword
    tenantName: admin           # Optional

development_1:
  provider: openstack
  auth_service:
    name:     identity
    host_uri: http://devstack:5000/v2.0
    request:  create_token
  auth_credentials:
    tokenId:    2c963f5512d067b24fdc312707c80c7a6d3d261b
    tenantName: admin

development_2:
  provider: openstack
  auth_service:
    name:     identity
    host_uri: http://devstack:5000/v2.0
    request:  create_token
  auth_credentials:
    username: admin
    password: mypassword
```

## CLI tools

```bash
# You may also query Aviator for the parameters via the CLI. With the Aviator gem 
# installed, run the following commands:

# list available providers
$ aviator describe

# list available services for openstack
$ aviator describe openstack

# list available requests for the openstack identity service
$ aviator describe openstack identity

# describe the create_tenant request of the identity service
$ aviator describe openstack identity create_tenant
```
  
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
