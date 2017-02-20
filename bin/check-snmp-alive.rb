#!/usr/bin/env ruby
# Check SNMP Alive
# ===
#
# Server, port, SNMP community, and Limits
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: snmp
#
# USAGE:
#
#   check-snmp-alive -h host -C community
#
# LICENSE:
#
#  Author Johan van den Dorpe <johan.vandendorpe@sohonet.com>
#
#  Based on snmp-check.rb by:
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

  option :snmp_version,
         short: '-v version',
         description: 'SNMP version to use (SNMPv1, SNMPv2c (default))',
         default: 'SNMPv2c'

  option :timeout,
         short: '-t timeout (seconds)',
         default: '1'

  option :retries,
         short: '-r retries',
         default: '1'

  option :debug,
         short: '-D',
         long: '--debug',
         description: 'Enable debugging to assist with inspecting OID values / data.',
         boolean: true,
         default: false

  def run
    begin
      manager = SNMP::Manager.new(host: config[:host].to_s,
                                  community: config[:community].to_s,
                                  version: config[:snmp_version].to_sym,
                                  retries: config[:retries].to_i,
                                  timeout: config[:timeout].to_i)
      # get sysDescr.0
      response = manager.get(['1.3.6.1.2.1.1.1.0'])
      if config[:debug]
        puts 'DEBUG OUTPUT:'
        response.each_varbind { |vb| puts vb.inspect }
      end
      ok "#{config[:host]} responded to SNMP request successfully"
    rescue SNMP::RequestTimeout
      critical "#{config[:host]} did not respond to SNMP request"
    rescue => e
      unknown "An unknown error occured: #{e.inspect}"
    end
    manager.close
  end

end
