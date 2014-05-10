# puppet-module-inittab
===

[![Build Status](https://api.travis-ci.org/ghoneycutt/puppet-module-inittab.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-inittab)

Puppet module to manage inittab

===

# Compatibility

#### Requires Puppet v3 and facter >= 1.7.0

Compatible with the following platforms.

* Debian 6 (squeeze)
* EL 5
* EL 6
* Solaris 10
* Solaris 11
* Suse 10
* Suse 11
* Ubuntu 12.04 LTS (Precise Pangolin)

===

# Parameters

default_runlevel
----------------
String for default runlevel. Valid values are 0-6, S, and s.

- *Default*: based on OS family. (runlevel 3 except Debian 6, which uses runlevel 2)

ensure_ttys1
------------
Optionally manage ttyS1. This will ensure that agetty spawns a tty which is needed for serial access. Valid values are 'present' and 'absent'. With `undef` the resource is not managed. Only applies to EL 6.

- *Default*: undef
