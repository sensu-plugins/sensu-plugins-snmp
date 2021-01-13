#!/usr/bin/env ruby
# frozen_string_literal: false

# SNMP Metrics
# ===
#
# This is a simple script to collect metrics from a SNMP OID value
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: snmp
#
# USAGE:
#
#   check-snmp -h host -P port -C community -O oid -p prefix -s suffix
#
# LICENSE:
#   Copyright (c) 2013 Double Negative Limited
#   Based on check-snmp.rb by Deepak Mohan Das   <deepakmdass88@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-plugin/metric/cli'
require 'snmp'

# Class that collects and outputs SNMP metrics in graphite format
class SNMPGraphite < Sensu::Plugin::Metric::CLI::Graphite
  option :host,
         short: '-h host',
         boolean: true,
         default: '127.0.0.1',
         required: true

  option :port,
         short: '-P port',
         long: '--port PORT',
         default: '161'

  option :community,
         short: '-C snmp community',
         boolean: true,
         default: 'public'

  option :objectid,
         short: '-O OID',
         default: '1.3.6.1.4.1.2021.10.1.3.1',
         required: true

  option :prefix,
         short: '-p prefix',
         description: 'prefix to attach to graphite path'

  option :suffix,
         short: '-s suffix',
         description: 'suffix to attach to graphite path',
         required: true

  option :snmp_version,
         short: '-v version',
         description: 'SNMP version to use (SNMPv1, SNMPv2c (default))',
         default: 'SNMPv2c'

  option :graphite,
         short: '-g',
         description: 'Replace dots with underscores in hostname',
         boolean: true

  option :mibdir,
         short: '-d mibdir',
         description: 'Full path to custom MIB directory.'

  option :mibs,
         short: '-l mib[,mib,mib...]',
         description: 'Custom MIBs to load (from custom mib path).',
         default: ''

  def run
    mibs = config[:mibs].split(',')
    begin
      manager = SNMP::Manager.new(host: config[:host].to_s, port: config[:port].to_i, community: config[:community].to_s, version: config[:snmp_version].to_sym)
      if config[:mibdir] && !mibs.empty?
        manager.load_modules(mibs, config[:mibdir])
      end
      response = manager.get([config[:objectid].to_s])
    rescue SNMP::RequestTimeout
      unknown "#{config[:host]} not responding"
    rescue StandardError => e
      unknown "An unknown error occured: #{e.inspect}"
    end
    config[:host] = config[:host].tr('.', '_') if config[:graphite]
    response.each_varbind do |vb|
      if config[:prefix]
        output "#{config[:prefix]}.#{config[:host]}.#{config[:suffix]}", vb.value.to_f
      else
        output "#{config[:host]}.#{config[:suffix]}", vb.value.to_f
      end
    end
    manager.close
    ok
  end
end
