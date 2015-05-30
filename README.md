## Sensu-Plugins-snmp

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-snmp.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-snmp)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-snmp.svg)](http://badge.fury.io/rb/sensu-plugins-snmp)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-snmp/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-snmp)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-snmp/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-snmp)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-snmp.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-snmp)

## Functionality

## Files
 * bin/check-snmp.rb
 * bin/metrics-snmp-bulk.rb
 * bin/metrics-snmp-if.rb
 * bin/metrics-snmp.rb

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-snmp -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-snmp`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-snmp' do
  options('--prerelease')
  version '0.0.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-snmp' do
  options('--prerelease')
  version '0.0.1'
end
```

## Notes
