#!/usr/bin/env ruby
# Check SNMP
# ===
#
# This is a simple SNMP check script for Sensu, We need to supply details like
# Server, port, SNMP community, and Limits
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: snmp
#
# USAGE:
#
#   check-snmp -h host -C community -O oid -w warning -c critical
#   check-snmp -h host -C community -O oid -m "(P|p)attern to match\.?"
#
# LICENSE:
#
#  Author Deepak Mohan Das   <deepakmdass88@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-plugin/check/cli'
require 'snmp'

# Class that checks the return from querying SNMP.
class CheckSNMP < Sensu::Plugin::Check::CLI
  option :host,
         short: '-h host',
         default: '127.0.0.1'

  option :community,
         short: '-C snmp community',
         default: 'public'

  option :objectid,
         short: '-O OID',
         default: '1.3.6.1.4.1.2021.10.1.3.1'

  option :warning,
         short: '-w warning',
         default: '10'

  option :critical,
         short: '-c critical',
         default: '20'

  option :match,
         short: '-m match',
         description: 'Regex pattern to match against returned value'

  option :snmp_version,
         short: '-v version',
         description: 'SNMP version to use (SNMPv1, SNMPv2c (default))',
         default: 'SNMPv2c'

  option :comparison,
         short: '-o comparison operator',
         description: 'Operator used to compare data with warning/critial values. Can be set to "le" (<=), "ge" (>=).',
         default: 'ge'

  option :convert_timeticks,
         short: '-T',
         long: '--convert-timeticks',
         description: 'Convert SNMP::TimeTicks to Integer for comparisons',
         boolean: true,
         default: 'false'

  option :timeout,
         short: '-t timeout (seconds)',
         default: '1'

  def run
    begin
      manager = SNMP::Manager.new(host: "#{config[:host]}",
                                  community: "#{config[:community]}",
                                  version: config[:snmp_version].to_sym,
                                  timeout: config[:timeout].to_i)
      response = manager.get(["#{config[:objectid]}"])
    rescue SNMP::RequestTimeout
      unknown "#{config[:host]} not responding"
    rescue => e
      unknown "An unknown error occured: #{e.inspect}"
    end
    operators = { 'le' => :<=, 'ge' => :>= }
    symbol = operators[config[:comparison]]

    response.each_varbind do |vb|
      if config[:match]
        if vb.value.to_s =~ /#{config[:match]}/
          ok
        else
          critical "Value: #{vb.value} failed to match Pattern: #{config[:match]}"
        end
      else
        snmp_value =  if config[:convert_timeticks]
                        vb.value.is_a?(SNMP::TimeTicks) ? vb.value.to_i : vb.value
                      else
                        vb.value
                      end

        critical 'Critical state detected' if "#{snmp_value}".to_i.send(symbol, "#{config[:critical]}".to_i)
        # #YELLOW
        warning 'Warning state detected' if ("#{snmp_value}".to_i.send(symbol, "#{config[:warning]}".to_i)) && !("#{snmp_value}".to_i.send(symbol, "#{config[:critical]}".to_i)) # rubocop:disable LineLength
        unless "#{snmp_value}".to_i.send(symbol, "#{config[:warning]}".to_i)
          ok 'All is well!'
        end
      end
    end
    manager.close
  end
end
