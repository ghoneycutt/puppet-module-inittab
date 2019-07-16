# == Class: inittab
#
# Manage inittab
#
class inittab (
  Variant[Integer, String] $default_runlevel                 = 'USE_DEFAULTS',
  Optional[Variant[Boolean,String]] $ensure_ttys1            = undef,
  Variant[Boolean,String] $file_mode                         = '0644',
  Variant[Boolean,String] $require_single_user_mode_password = false,
  Variant[Boolean,String] $enable_ctrlaltdel                 = true,
  Variant[Boolean,String] $ctrlaltdel_override_path          = 'USE_DEFAULTS',
  Variant[Array,String] $ctrlaltdel_override_owner           = 'root',
  Variant[Array,String] $ctrlaltdel_override_group           = 'root',
  Variant[Boolean,String] $ctrlaltdel_override_mode          = '0644',
) {

  if $ensure_ttys1 {
    validate_re($ensure_ttys1,'^(present)|(absent)$',"inittab::ensure_ttys1 is ${ensure_ttys1} and if defined must be \'present\' or \'absent\'.")
  }

  validate_re($file_mode, '^[0-7]{4}$',
    "inittab::file_mode is <${file_mode}> and must be a valid four digit mode in octal notation.")

  if is_string($require_single_user_mode_password) {
    $require_single_user_mode_password_bool = str2bool($require_single_user_mode_password)
  } else {
    $require_single_user_mode_password_bool = $require_single_user_mode_password
  }
  validate_bool($require_single_user_mode_password_bool)

  if is_string($enable_ctrlaltdel) {
    $enable_ctrlaltdel_bool = str2bool($enable_ctrlaltdel)
  } else {
    $enable_ctrlaltdel_bool = $enable_ctrlaltdel
  }
  validate_bool($enable_ctrlaltdel_bool)

  validate_string($ctrlaltdel_override_owner)

  validate_string($ctrlaltdel_override_group)

  validate_re($ctrlaltdel_override_mode, '^[0-7]{4}$',
    "inittab::ctrlaltdel_override_mode is <${ctrlaltdel_override_mode}> and must be a valid four digit mode in octal notation.")

  case $facts['osfamily'] {
    'RedHat': {
      case $facts['operatingsystemrelease'] {
        /^5/: {
          $default_default_runlevel    = 3
          $template                    = 'inittab/el5.erb'
          $support_ctrlaltdel_override = false
          $systemd                     = false
        }
        /^6/: {
          $default_default_runlevel         = 3
          $template                         = 'inittab/el6.erb'
          $support_ctrlaltdel_override      = true
          $default_ctrlaltdel_override_path = '/etc/init/control-alt-delete.override'
          $systemd                          = false

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
        /^7/: {
          $default_default_runlevel    = 3
          $template                    = 'inittab/el7.erb'
          $support_ctrlaltdel_override = false
          $systemd                     = true
        }
        default: {
          fail("operatingsystemrelease is <${facts['operatingsystemrelease']}> and inittab supports RedHat versions 5, 6 and 7.")
        }
      }
    }
    'Debian': {
      $support_ctrlaltdel_override = false
      $systemd                     = false

      if $facts['operatingsystem'] == 'Ubuntu' {

        $default_default_runlevel         = 3
        $template                         = 'inittab/ubuntu.erb'

      } else {

        case $facts['operatingsystemmajrelease'] {
          '6': {
            $default_default_runlevel = 2
            $template                 = 'inittab/debian6.erb'
          }
          default: {
            fail("operatingsystemmajrelease is <${facts['operatingsystemmajrelease']}> and inittab supports Debian version 6.")
          }
        }
      }
    }
    'Solaris': {
      $support_ctrlaltdel_override = false
      $systemd                     = false

      case $facts['kernelrelease'] {
        '5.10': {
          $default_default_runlevel = 3
          $template                 = 'inittab/sol10.erb'
        }
        '5.11': {
          $default_default_runlevel = 3
          $template                 = 'inittab/sol11.erb'
        }
        default: {
          fail("kernelrelease is <${facts['kernelrelease']}> and inittab supports Solaris versions 5.10 and 5.11.")
        }
      }
    }
    'Suse':{
      $support_ctrlaltdel_override = false
      $systemd                     = false

      case $facts['operatingsystemrelease'] {
        /^10/: {
          $default_default_runlevel = 3
          $template                 = 'inittab/suse10.erb'
        }
        /^11/: {
          $default_default_runlevel = 3
          $template                 = 'inittab/suse11.erb'
        }
        /^12/: {
          $default_default_runlevel = 3
          $template                 = 'inittab/suse12.erb'
        }
        default: {
          fail("operatingsystemrelease is <${facts['operatingsystemrelease']}> and inittab supports Suse versions 10 and 11.")
        }
      }
    }
    default: {
      fail("osfamily is <${facts['osfamily']}> and inittab module supports Debian, RedHat, Ubuntu, Suse and Solaris.")
    }
  }

  if $default_runlevel == 'USE_DEFAULTS' {
    $default_runlevel_real = $default_default_runlevel
  } else {
    $default_runlevel_real = $default_runlevel
  }

  # convert integer to string
  if type3x($default_runlevel_real) == 'integer' {
    $default_runlevel_real_string = "${default_runlevel_real}" # lint:ignore:only_variable_string
  }

  # validate default_runlevel_real
  validate_re($default_runlevel_real_string, '^[0-6sS]$',
    "default_runlevel <${default_runlevel_real}> does not match regex")

  if $enable_ctrlaltdel_bool == true {
    $ctrlaltdel_override_ensure = 'absent'
    $ctrlaltdel_target = '/lib/systemd/system/ctrl-alt-del.target'
  } else {
    $ctrlaltdel_override_ensure = 'file'
    $ctrlaltdel_target = '/dev/null'
  }

  if $facts['operatingsystem'] == 'Ubuntu' {
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

  if $systemd == true {
    case $default_runlevel_real {
      3: {
        $target = '/lib/systemd/system/multi-user.target'
      }
      5: {
        $target = '/lib/systemd/system/graphical.target'
      }
      default: {
        fail("default_runlevel for EL7 is <${default_runlevel_real}> and must be 3 or 5.")
      }
    }

    file { '/etc/systemd/system/default.target':
      ensure => 'link',
      target => $target,
    }

    file { '/etc/systemd/system/ctrl-alt-del.target':
      ensure => 'link',
      target => $ctrlaltdel_target,
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

    if $systemd == false {
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
}
