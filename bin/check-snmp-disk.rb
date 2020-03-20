#! /usr/bin/env ruby
# frozen_string_literal: false

#
#   check-snmp-disk
#
# DESCRIPTION:
#
#   This is a simple SNMP check disk script for Sensu,
#   The tool get a mount point as a regex and search for it in the device description SNMP table
#   and return the utilization status based on warning and critical thresholds
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: SNMP
#
# USAGE:
#   check-snmp -h host -C public -m /mnt -w 75 -c 85
#
#   if you want to search for specific device and not regex add a comma to the pattern:
#   check-snmp -h host -C public -m /,
#
# NOTES:
#   To search for device description in your server or applicance run the following command:
#   snmpwalk -v2c -c public host 1.3.6.1.2.1.25.2.3.1.3
#
#  LICENSE:
#    Yossi Nachum   <nachum234@gmail.com>
#    Released under the same terms as Sensu (the MIT license); see LICENSE
#    for details.
#

require 'sensu-plugin/check/cli'
require 'snmp'

class CheckSNMP < Sensu::Plugin::Check::CLI
  option :host,
         short: '-h host',
         default: '127.0.0.1',
         description: 'SNMP hostname'

  option :port,
         short: '-P port',
         long: '--port PORT',
         default: '161'

  option :community,
         short: '-C snmp community',
         default: 'public',
         description: 'SNMP community'

  option :mount_point,
         short: '-m mount point',
         default: '/',
         description: 'Disk mount point'

  option :ignoremnt,
         short: '-i MNT[,MNT]',
         description: 'Ignore mount point(s)',
         proc: proc { |a| a.split(',') }

  option :warning,
         short: '-w warning',
         proc: proc(&:to_i),
         default: 80,
         description: 'Warning threshold in precentage'

  option :critical,
         short: '-c critical',
         proc: proc(&:to_i),
         default: 90,
         description: 'Critical threshold in precentage'

  option :snmp_version,
         short: '-v version',
         description: 'SNMP version to use (SNMPv1, SNMPv2c (default))',
         default: 'SNMPv2c'

  option :timeout,
         short: '-t timeout (seconds)',
         default: '1',
         description: 'SNMP timeout'

  def initialize
    super
    @crit_mnt = []
    @warn_mnt = []
  end

  def usage_summary
    (@crit_mnt + @warn_mnt).join(', ')
  end

  def run
    base_oid = '1.3.6.1.2.1.25.2.3.1'
    dev_desc_oid = base_oid + '.3'
    dev_size_oid = base_oid + '.5'
    dev_used_oid = base_oid + '.6'
    begin
      manager = SNMP::Manager.new(host: config[:host].to_s,
                                  port: config[:port].to_i,
                                  community: config[:community].to_s,
                                  version: config[:snmp_version].to_sym,
                                  timeout: config[:timeout].to_i)
      response = manager.get_bulk(0, 200, [dev_desc_oid])
      dev_indexes = []
      response.each_varbind do |var|
        next if config[:ignoremnt] && config[:ignoremnt].include?(var.value.to_s.split(',')[0])
        if var.value.to_s =~ /#{config[:mount_point]}/
          dev_indexes.push(var.name[-1])
        end
      end
      dev_indexes.each do |dev_index|
        response = manager.get(["#{dev_desc_oid}.#{dev_index}", "#{dev_size_oid}.#{dev_index}", "#{dev_used_oid}.#{dev_index}"])
        dev_desc, dev_size, dev_used = response.varbind_list
        perc = dev_used.value.to_f / dev_size.value.to_f * 100
        if perc > config[:critical]
          @crit_mnt << "#{dev_desc.value} = #{perc.round(2)}%"
        elsif perc > config[:warning]
          @warn_mnt << "#{dev_desc.value} = #{perc.round(2)}%"
        end
      end
    rescue SNMP::RequestTimeout
      unknown "#{config[:host]} not responding"
    rescue => e
      unknown "An unknown error occured: #{e.inspect}"
    end
    critical usage_summary unless @crit_mnt.empty?
    warning usage_summary unless @warn_mnt.empty?
    ok "All disk usage under #{config[:warning]}%"
    manager.close
  end
end
