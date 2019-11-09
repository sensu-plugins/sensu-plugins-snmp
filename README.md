[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-snmp)
[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-snmp.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-snmp)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-snmp.svg)](http://badge.fury.io/rb/sensu-plugins-snmp)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-snmp/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-snmp)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-snmp/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-snmp)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-snmp.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-snmp)

## Sensu SNMP Plugin

- [Overview](#overview)
- [Usage examples](#usage-examples)
- [Configuration](#configuration)
  - [Sensu Go](#sensu-go)
    - [Asset manifest](#asset-manifest)
    - [Check manifest](#check-manifest)
  - [Sensu Core](#sensu-core)
    - [Check definition](#check-definition)
- [Installation](#installation)

### Overview

This plugin provides native SNMP instrumentation for monitoring and metrics collection, including: generic OID single/bulk query for status and metrics, and ifTable metrics.

#### Files
 * bin/check-snmp.rb
 * bin/check-snmp-disk.rb
 * bin/metrics-snmp-bulk.rb
 * bin/metrics-snmp-if.rb
 * bin/metrics-snmp.rb

## Usage examples

**metrics-snmp.rb**
```
Usage: metrics-snmp.rb (options)
    -C snmp community
    -g                               Replace dots with underscores in hostname
    -h host
    -d mibdir                        Full path to custom MIB directory.
    -l mib[,mib,mib...]              Custom MIBs to load (from custom mib path).
    -O OID
    -P, --port PORT
    -p prefix                        prefix to attach to graphite path
    -v version                       SNMP version to use (SNMPv1, SNMPv2c (default))
    -s suffix                        suffix to attach to graphite path (required)
```

### Configuration
#### Sensu Go
##### Asset registration

Assets are the best way to make use of this handler. If you're not using an asset, please consider doing so! If you're using sensuctl 5.13 or later, you can use the following command to add the asset: 

`sensuctl asset add sensu-plugins/sensu-plugins-snmp`

If you're using an earlier version of sensuctl, you can download the asset definition from [this project's Bonsai Asset Index page](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-snmp).

##### Asset manifest

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-plugins-snmp
spec:
  url: https://assets.bonsai.sensu.io/cd39e88ca50bf16793796429a94673df208ddb26/sensu-plugins-snmp_3.0.0-pre_centos_linux_amd64.tar.gz
  sha512: 7edd57dab82bfd97662d3f2d6ddfb70c41bbcba591b1c2c4077d0107c667fbd2c64ad2bcef51e0192e18176ade60fde403c4784ac141ba1a932cc65c8c897169
  filters:
  - entity.system.os == 'linux'
  - entity.system.arch == 'amd64'
  - entity.system.platform_family == 'rhel'
```

##### Check manifest

```yaml
---
type: CheckConfig
spec:
  command: "metrics-snmp.rb -h 10.0.0.1 -O 1.2.3.4.5"
  interval: 10
  publish: true
  runtime_assets:
  - sensu-plugins-snmp
  - sensu-ruby-runtime
  subscriptions:
  - snmp-pollers
  output_metric_format: graphite_plaintext
  output_metric_handlers:
  - influx-db
```
#### Sensu Core
##### Check definition
```json
{
  "checks": {
    "check-snmp": {
    "command": "metrics-snmp.rb -h 10.0.0.1 -O 1.2.3.4.5",
    "subscribers": [
      "snmp-pollers"
    ],
    "interval": 60
    }
  }
}
```

## Installation

### Sensu Go

See the instructions above for [asset registration](#asset-registration)

### Sensu Core
Install and setup plugins on [Sensu Core](https://docs.sensu.io/sensu-core/latest/installation/installing-plugins/)
