#!/usr/bin/env ruby
# frozen_string_literal: false

# SNMP Bulk Metrics
# ===
#
# This is a script to 'bulk walk' an SNMP OID value, collecting metrics
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: snmp
#
# USAGE:
#
#   snmp-bulk-metrics -h host -C community -O oid1,oid2...
#
# LICENSE:
#   Copyright 2014 Matthew Richardson <m.richardson@ed.ac.uk>
#   Based on snmp-metrics.rb by Double Negative Limited
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
         short: '-O OID[,OID,OID...]',
         description: 'comma separated list of OIDs to bulkwalk',
         required: true

  option :prefix,
         short: '-p prefix',
         description: 'prefix to attach to graphite path'

  option :suffix,
         short: '-s suffix',
         description: 'suffix to attach to graphite path'

  option :snmp_version,
         short: '-v version',
         description: 'SNMP version to use (SNMPv1, SNMPv2c (default))',
         default: 'SNMPv2c'

  option :graphite,
         short: '-g',
         description: 'Replace dots with underscores in hostname',
         boolean: true

  option :maxrepeat,
         short: '-m maxrepeat',
         description: 'Number of iterations to perform on repeating variables (defaults to 10)',
         default: 10

  option :nonrepeat,
         short: '-n non-repeaters',
         description: 'Number of supplied OIDs that should not be iterated over (defaults to 0)',
         default: 0

  option :mibdir,
         short: '-d mibdir',
         description: 'Full path to custom MIB directory.'

  option :mibs,
         short: '-l mib[,mib,mib...]',
         description: 'Custom MIBs to load (from custom mib path).',
         default: ''

  option :timeout,
         short: '-t timeout (seconds) (defaults to 5)',
         default: 5

  def run
    oids = config[:objectid].split(',')
    mibs = config[:mibs].split(',')
    begin
      manager = SNMP::Manager.new(host: config[:host].to_s,
                                  port: config[:port].to_i,
                                  community: config[:community].to_s,
                                  version: config[:snmp_version].to_sym,
                                  timeout: config[:timeout].to_i)
      if config[:mibdir] && !mibs.empty?
        manager.load_modules(mibs, config[:mibdir])
      end
      response = manager.get_bulk(config[:nonrepeat].to_i,
                                  config[:maxrepeat].to_i,
                                  oids)
    rescue SNMP::RequestTimeout
      unknown "#{config[:host]} not responding"
    rescue StandardError => e
      unknown "An unknown error occured: #{e.inspect}"
    end
    config[:host] = config[:host].tr('.', '_') if config[:graphite]
    response.each_varbind do |vb|
      name = vb.oid
      name = name.to_s.tr('.', '_') if config[:graphite]
      begin
        metric_string = config[:host]
        metric_string = "#{config[:prefix]}.#{metric_string}" if config[:prefix]
        metric_string += ".#{config[:suffix]}" if config[:suffix]
        metric_string += ".#{name}"
        output metric_string, vb.value.to_f
      rescue NameError # rubocop:disable Lint/SuppressedExceptions
        # Rescue as some values may fail to cast to float
      end
    end
    manager.close
    ok
  end
end
