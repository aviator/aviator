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

# Create a new session
session = Aviator::Session.new(
            config_file: 'path/to/aviator.yml',
            environment: :production,
            log_file:    'path/to/aviator.log'
          )

# Authenticate against the auth service specified in :config_file
session.authenticate


# Aviator::Session automatically keeps track of your authentication data in an in-memory
# keychain. For example, the authentication data from above is automatically stored 
# in `session.keys[:default]`

# To create another key, just call Session#authenticate with an extra parameter:
session.authenticate(key_name: 'anotherkey') do |credentials|
  credentials[:username]   = myusername
  credentials[:password]   = mypassword
  credentials[:tenantName] = tenantName
end

# You can access the key at:
session.keys['anotherkey']

# Or you can create another session object that uses that key by default:
session2 = session.use_key('anotherkey')

# Get connection to the Identity Service using the token in the default key
keystone = session.identity_service

# Get connection to the Identity Service using the token in the 'anotherkey' key
keystone2 = session2.identity_service


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


# Be explicit about the endpoint type to use. Useful in the rare instances when
# the same request name means differently depending on the endpoint type.
response = keystone.request(:list_tenants, endpoint_type: 'admin') do |params|
  params['tenantName'] = tenant_name
end
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
