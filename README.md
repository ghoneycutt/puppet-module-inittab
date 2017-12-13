# puppet-module-inittab
===

Puppet module to manage inittab. To use this module simply `include
::inittab`.

===

# Compatibility

Works with Puppet v3 (with and without future parser) and Puppet v4 with
Ruby versions 1.8.7, 1.9.3, 2.0.0 and 2.1.9 on the following platforms.
See `.travis.yml` for an exact matrix of Puppet and Ruby versions.

* Debian 6 (squeeze)
* EL 5
* EL 6
* EL 7
* Solaris 10
* Solaris 11
* Suse 10
* Suse 11
* Suse 12
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

file_mode
---------
String of file mode in four digit octal notation for inittab.

- *Default*: '0644'

require_single_user_mode_password
---------------------------------
Boolean to require a password when selecting Single User Mode. EL 5 only.

- *Default*: false

enable_ctrlaltdel
-----------------
Boolean to enable control-alt-delete. Supported on Linux systems. If set to false, the command `exec logger "control-alt-delete issued"` will be triggered whenever control-alt-delete is issued.

- *Default*: true

ctrlaltdel_override_path
------------------------
String of path to control-alt-delete.override. Only used on EL 6, which is '/etc/init/control-alt-delete.override'.

- *Default*: 'USE_DEFAULTS'

ctrlaltdel_override_owner
-------------------------
String of owner for control-alt-delete.override file. Only used on EL 6.

- *Default*: 'root'

ctrlaltdel_override_group
-------------------------
String of group for control-alt-delete.override file. Only used on EL 6.

- *Default*: 'root'

ctrlaltdel_override_mode
------------------------
String of four digital octal mode of control-alt-delete.override file. Only used on EL 6.

- *Default*: '0644'
