### v2.9.2 - 2018-06-11
  Fix for EL7

### v2.9.1 - 2016-11-17
  (maint) Fix ruby dependencies
  Explicitly support puppet-lint v2

### v2.9.0 - 2016-08-31
  Add support for Ruby v2.3.1
  Add support for strict variable checking

### v2.8.1
   Documentation changes to get Approved status

   * Bump year in LICENSE
   * Add CHANGELOG
   * Document usage of module
   * Use https in fixtures for easier use behind corp firewalls

### v2.8.0
  Support Puppet v4 and v3 with future parser

### v2.7.1
  deprecate type()

### v2.7.0
  Add support for EL7

### v2.6.0
  Support Suse 12

### v2.5.0
  Can require password in single user mode on EL 5

### v2.4.1
  bugfix!

  With 2.4.0 EL 6 would always disable control-alt-delete

### v2.4.0
  ability to disable ctrl-alt-del

### v2.3.0
  Add ability to specify mode of inittab

### v2.2.0
  manage tty for serial comms on EL 6

### v2.1.3
  Fix detection on EL systems

  This release fixes an issue where operatingsystemmajrelease was not present
  and uses operatingsystemrelease with a regex to detect the major release
  number of the OS.

### v2.1.2
  simplify ubuntu support

### v2.1.1
  Restore support for Suse

  Mike Lehner (mlehner616) switched out operatingsystemmajrelease for
  operatingsystemrelease and used regex to only grab the major version which
  works around a facter issue of operatingsystemmajrelease not working.

### v2.0.0
  Require Facter >= 1.7.0

### v1.1.1
  fix deprecation warnings in template

### v1.1.0
  Support Suse 10

### v1.0.1
  bugfix for Solaris 10

### v1.0.0
  First full release.

### 0.0.1
  2013-05-16 Garrett Honeycutt <code@garretthoneycutt.com> - Initial release
