# == Class: inittab
#
# Manage inittab
#
class inittab (
  $default_runlevel          = 'USE_DEFAULTS',
  $ensure_ttys1              = undef,
  $file_mode                 = '0644',
  $enable_ctrlaltdel         = true,
  $ctrlaltdel_override_path  = 'USE_DEFAULTS',
  $ctrlaltdel_override_owner = 'root',
  $ctrlaltdel_override_group = 'root',
  $ctrlaltdel_override_mode  = '0644',
) {

  if $ensure_ttys1 {
    validate_re($ensure_ttys1,'^(present)|(absent)$',"inittab::ensure_ttys1 is ${ensure_ttys1} and if defined must be \'present\' or \'absent\'.")
  }

  validate_re($file_mode, '^[0-7]{4}$',
    "inittab::file_mode is <${file_mode}> and must be a valid four digit mode in octal notation.")

  if type($enable_ctrlaltdel) == 'string' {
    $enable_ctrlaltdel_bool = str2bool($enable_ctrlaltdel)
  } else {
    $enable_ctrlaltdel_bool = $enable_ctrlaltdel
  }
  validate_bool($enable_ctrlaltdel_bool)

  validate_string($ctrlaltdel_override_owner)

  validate_string($ctrlaltdel_override_group)

  validate_re($ctrlaltdel_override_mode, '^[0-7]{4}$',
    "inittab::ctrlaltdel_override_mode is <${ctrlaltdel_override_mode}> and must be a valid four digit mode in octal notation.")

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemrelease {
        /^5/: {
          $default_default_runlevel    = 3
          $template                    = 'inittab/el5.erb'
          $support_ctrlaltdel_override = false
        }
        /^6/: {
          $default_default_runlevel         = 3
          $template                         = 'inittab/el6.erb'
          $support_ctrlaltdel_override      = true
          $default_ctrlaltdel_override_path = '/etc/init/control-alt-delete.override'

          if $ensure_ttys1 {
            file { 'ttys1_conf':
              ensure => $ensure_ttys1,
              path   => '/etc/init/ttyS1.conf',
              source => 'puppet:///modules/inittab/ttyS1.conf',
              owner  => 'root',
              group  => 'root',
              mode   => '0644',
            }
          }

          if $ensure_ttys1 == 'present' {
            service { 'ttyS1':
              ensure     => running,
              hasstatus  => false,
              hasrestart => false,
              start      => '/sbin/initctl start ttyS1',
              stop       => '/sbin/initctl stop ttyS1',
              status     => '/sbin/initctl status ttyS1 | grep ^"ttyS1 start/running" 1>/dev/null 2>&1',
              require    => File['ttys1_conf'],
            }
          }
        }
        default: {
          fail("operatingsystemrelease is <${::operatingsystemrelease}> and inittab supports RedHat versions 5 and 6.")
        }
      }
    }
    'Debian': {
      $support_ctrlaltdel_override = false

      if $::operatingsystem == 'Ubuntu' {

        $default_default_runlevel         = 3
        $template                         = 'inittab/ubuntu.erb'

      } else {

        case $::operatingsystemmajrelease {
          '6': {
            $default_default_runlevel = 2
            $template                 = 'inittab/debian6.erb'
          }
          default: {
            fail("operatingsystemmajrelease is <${::operatingsystemmajrelease}> and inittab supports Debian version 6.")
          }
        }
      }
    }
    'Solaris': {
      $support_ctrlaltdel_override = false

      case $::kernelrelease {
        '5.10': {
          $default_default_runlevel = 3
          $template                 = 'inittab/sol10.erb'
        }
        '5.11': {
          $default_default_runlevel = 3
          $template                 = 'inittab/sol11.erb'
        }
        default: {
          fail("kernelrelease is <${::kernelrelease}> and inittab supports Solaris versions 5.10 and 5.11.")
        }
      }
    }
    'Suse':{
      $support_ctrlaltdel_override = false

      case $::operatingsystemrelease {
        /^10/: {
          $default_default_runlevel = 3
          $template                 = 'inittab/suse10.erb'
        }
        /^11/: {
          $default_default_runlevel = 3
          $template                 = 'inittab/suse11.erb'
        }
        default: {
          fail("operatingsystemrelease is <${::operatingsystemrelease}> and inittab supports Suse versions 10 and 11.")
        }
      }
    }
    default: {
      fail("osfamily is <${::osfamily}> and inittab module supports Debian, RedHat, Ubuntu, Suse, and Solaris.")
    }
  }

  if $default_runlevel == 'USE_DEFAULTS' {
    $default_runlevel_real = $default_default_runlevel
  } else {
    $default_runlevel_real = $default_runlevel
  }

  # validate default_runlevel_real
  validate_re($default_runlevel_real, '^[0-6sS]$', "default_runlevel <${default_runlevel_real}> does not match regex")

  if $enable_ctrlaltdel_bool == true {
    $ctrlaltdel_override_ensure = 'file'
  } else {
    $ctrlaltdel_override_ensure = 'absent'
  }

  if $::operatingsystem == 'Ubuntu' {
    file { 'rc-sysinit.override':
      ensure  => file,
      path    => '/etc/init/rc-sysinit.override',
      content => template($template),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  } else {
    file { 'inittab':
      ensure  => file,
      path    => '/etc/inittab',
      content => template($template),
      owner   => 'root',
      group   => 'root',
      mode    => $file_mode,
    }
  }

  validate_bool($support_ctrlaltdel_override)

  if $support_ctrlaltdel_override == true {

    if $ctrlaltdel_override_path == 'USE_DEFAULTS' {
      $ctrlaltdel_override_path_real = $default_ctrlaltdel_override_path
    } else {
      $ctrlaltdel_override_path_real = $ctrlaltdel_override_path
    }
    validate_absolute_path($ctrlaltdel_override_path_real)

    file { 'ctrlaltdel_override':
      ensure  => $ctrlaltdel_override_ensure,
      path    => $ctrlaltdel_override_path_real,
      content => template('inittab/control-alt-delete.override.erb'),
      owner   => $ctrlaltdel_override_owner,
      group   => $ctrlaltdel_override_group,
      mode    => $ctrlaltdel_override_mode,
    }
  }
}
