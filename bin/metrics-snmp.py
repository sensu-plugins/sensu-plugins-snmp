#!/usr/bin/env python
# SNMP Metrics
# ===
#
# Collect metrics from a host via SNMP. Requires at least one OID
# defined via a YAML config file.
# Prints to stdout in Graphite plain text protocol format and as such is meant
# to be consumed by a Graphite handler.

# Yaml Config file must have the following keys
# id,target,community,schema,oids(hash)
# e.g.
#id: my-device
#target: 10.10.10.10
#community: snmp_foobar_community_string
#schema: my.graphite.schema
#oids:
# bytes_in: ".1.3.6.1.2.1.31.1.1.1.6.516"
# bytes_out: ".1.3.6.1.2.1.31.1.1.1.10.516"
#
# Which will result in the following output:

# my.graphite.schema.my-device.bytes_out 18553950490121 1458008691.33
# my.graphite.schema.my-device.bytes_out 84920238682950 1458008691.33
#
# USAGE:
#   metrics-snmp.py -c some_device.yml [-s 1|2|3] [-K] [--help]
#
# DEPENDENCIES:
#  Python: 2.7.x (Untested on 3.x but *should* work)
#  Python: easysnmp https://github.com/fgimian/easysnmp
#
# Author: Jaime Gago <contact@jaimegago.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

import argparse
import easysnmp
import re
import sys
import time
import yaml

def read_yaml(yaml_file):
  try:
    with open(yaml_file, 'r') as stream:
      return yaml.load(stream)
  except Exception as e:
    print 'Problem reading conf file,not valid YAML %s' % yaml_file
    print e
    sys.exit(1)

def snmp_source_conf_validator(conf, conf_file_path):
  error_msg = 'Conf file is not valid : %s' % conf_file_path
  try:
    isinstance(conf, dict)
  except Exception as e:
    print error_msg
    print 'INVALID FORMAT'
    sys.exit(1)

  try:
    conf['target']
    conf['schema']
    conf['community']
    conf['id']
    conf['oids']
  except Exception as e:
    print error_msg
    print 'Missing key'
    print e
    sys.exit(1)

def load_config(conf_file_path):
  conf = read_yaml(conf_file_path)
  snmp_source_conf_validator(conf, conf_file_path)
  return conf

def get_snmp_stats(device_name, target, community, metrics_oids, schema, now,
    snmp_version):
  snmp_session = easysnmp.Session(hostname=target, community=community,
      version=snmp_version)
  try:
    reported = 0
    for metric in metrics_oids:
      oid = metrics_oids[metric]
      snmp_response = snmp_session.get(oid)
      value = snmp_response.value
      print '%s.%s.%s %s %s' % (schema, device_name, metric, value, now)
      reported += 1
    return reported
  except Exception as e:
    print e
    sys.exit(1)


def parse_cmdline(args):
  desc = 'Grab SNMP stats as per config file'
  parser = argparse.ArgumentParser(description=desc)

  parser.add_argument('-c', '--conf_file',
      help = 'path to file containing SNMP device details',
      required = True)

  parser.add_argument('-s', '--snmp_version',
      help = 'SNMP version, defaults to 2 (==2c), possible values are 1,2,3',
      default = 2)

  parser.add_argument('-K', '--unknown-on-empty',
      help    = 'return UNKNOWN if no metrics were reported',
      default = False,
      dest    = 'unknown_on_empty')

  options = parser.parse_args(args)

  return options

def main(args):
  options = parse_cmdline(args)
  now = time.time()
  conf = load_config(options.conf_file)
  schema = conf['schema']
  dev_name = conf['id']
  target = conf['target']
  community = conf['community']
  metrics_oids = conf['oids']
  reported = get_snmp_stats(dev_name, target, community, metrics_oids, schema, now,
      options.snmp_version)
  if reported == 0 and options.unknown_on_empty:
    sys.exit(3)


if __name__ == '__main__':
  sys.exit(main(sys.argv[1:]))
