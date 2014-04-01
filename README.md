vCloud Launcher
===============
A tool that takes a YAML or JSON configuration file describing a vDC, and provisions
the vApps and VMs contained within.

### Supports

    Configuration of multiple vApps/VMs with:
        multiple NICs
        custom CPU and memory size
        multiple additional disks
        custom VM metadata
    Basic idempotent operation - vApps that already exist are skipped.

### Limitations

    Source vApp Template must contain a single VM. This is VMware's recommended 'simple' method of vApp creation. Complex multi-VM vApps are not supported.
    Org vDC Networks must be precreated.
    IP addresses are assigned manually (recommended) or via DHCP. VM IP pools are not supported.
    vCloud has some interesting ideas about the size of potential 'guest customisation scripts' (aka preambles). You may need to use an external minify tool to reduce the size, or speak to your provider to up the limit. 2048 bytes seems to be a practical default maximum.

## Installation

Add this line to your application's Gemfile:

    gem 'vcloud-launcher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vcloud-launcher


## Usage

vCloud Launcher uses [Fog](http://fog.io/).

To use it you need a .fog file in your home directory.

For example:

test:
  vcloud_director_username: 'username@org_name'
  vcloud_director_password: 'password'
  vcloud_director_host: 'host.api.example.com'

Unfortunately current usage of fog requires the password in this file. Multiple sets of credentials can be specified in the fog file, using the following format:

test:
  vcloud_director_username: 'username@org_name'
  vcloud_director_password: 'password'
  vcloud_director_host: 'host.api.example.com'

test2:
  vcloud_director_username: 'username@org_name'
  vcloud_director_password: 'password'
  vcloud_director_host: 'host.api.vendor.net'

You can then pass the FOG_CREDENTIAL environment variable at the start of your command. The value of the FOG_CREDENTIAL environment variable is the name of the credential set in your fog file which you wish to use. For instance:

FOG_CREDENTIAL=test2 vcloud-launch node.yaml

An example configuration file is located in examples/vcloud-launch

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Other settings

vCloud Launcher uses vCloud Core. If you want to use the latest version of vCloud Core, or a local version, you can export some variables. See the Gemfile for details.

## Testing

Default target: `bundle exec rake`
Runs the unit and feature tests (pretty quick right now)

* Unit tests only: `bundle exec rake spec`
* Integration tests ('quick' tests): `bundle exec rake integration:quick`
* Integration tests (all tests - takes 20mins+): `bundle exec rake integration:all`

You need access to a suitable vCloud Director organization to run the
integration tests. It is not necessarily safe to run them against an existing
environment, unless care is taken with the entities being tested.

The easiest thing to do is create a local shell script called
`vcloud_env.sh` and set the contents:

    export FOG\_CREDENTIAL=test
    export VCLOUD\_VDC\_NAME="Name of the VDC"
    export VCLOUD\_CATALOG\_NAME="catalog-name"
    export VCLOUD\_TEMPLATE\_NAME="name-of-template"
    export VCLOUD\_NETWORK1\_NAME="name-of-primary-network"
    export VCLOUD\_NETWORK2\_NAME="name-of-secondary-network"
    export VCLOUD\_NETWORK1\_IP="ip-on-primary-network"
    export VCLOUD\_NETWORK2\_IP="ip-on-secondary-network"
    export VCLOUD\_TEST\_STORAGE\_PROFILE="storage-profile-name"
    export VCLOUD\_EDGE\_GATEWAY="name-of-edge-gateway-in-vdc"

Then run this before you run the integration tests.

### Specific integration tests

#### Storage profile tests

There is an integration test to check storage profile behaviour, but it requires a lot of set-up so it is not called by the rake task. If you wish to run it you need access to an environment that has two VDCs, each one containing a storage profile with the same name. This named storage profile needs to be different from teh default storage profile.

You will need to set the following environment variables:

      export VDC\_NAME\_1="Name of the first vDC"
      export VDC\_NAME\_2="Name of the second vDC"
      export VCLOUD\_CATALOG\_NAME="Catalog name" # Can be the same as above settings if appropriate
      export VCLOUD\_TEMPLATE\_NAME="Template name" # Can be the same as above setting if appropriate
      export VCLOUD\_STORAGE\_PROFILE\_NAME="Storage profile name" # This needs to exist in both vDCs
      export VDC\_1\_STORAGE\_PROFILE\_HREF="Href of the named storage profile in vDC 1"
      export VDC\_2\_STORAGE\_PROFILE\_HREF="Href of the named storage profile in vDC 2"
      export DEFAULT\_STORAGE\_PROFILE\_NAME="Default storage profile name"
      export DEFAULT\_STORAGE\_PROFILE\_HREF="Href of default storage profile"

To run this test: `rspec spec/integration/launcher/storage_profile_integration_test.rb`
