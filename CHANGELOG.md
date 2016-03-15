#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]

## [0.2.0] - 2016-03-14
### Added
- Added a YAML config file based SNMP metrics (graphite) plugin

## [0.1.0] - 2015-11-13
### Added
- Added a script check-snmp-disk, that checks disk utilization using SNMP

## [0.0.4] - 2015-07-22
### Fixed
- Fixed graphite output when using a prefix in metrics-snmp-bulk.rb

### Added
- Made suffix an optional flag in metrics-snmp-bulk.rb so you can choose exactly how to format your metrics output

## [0.0.3] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.2] - 2015-06-03
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - 2015-04-30
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-iis/compare/0.1.0...HEAD
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-iis/compare/0.0.4...0.1.0
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-iis/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-iis/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-iis/compare/0.0.1...0.0.2
