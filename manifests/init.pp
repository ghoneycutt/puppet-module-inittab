# ## Class: inittab ##
#
# Manage inittab
#
# ### Parameters ###
#
# default_runlevel
# ----------------
# String for default runlevel
#
# - *Default*: 3
#
class inittab (
  $default_runlevel = 'USE_DEFAULTS',
) {

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '5': {
          $default_default_runlevel = 3
          $template                 = 'inittab/el5.erb'
        }
        '6': {
          $default_default_runlevel = 3
          $template                 = 'inittab/el6.erb'
        }
        default: {
          fail("operatingsystemmajrelease is <${::operatingsystemmajrelease}> and inittab supports RedHat versions 5 and 6.")
        }
      }
    }
    'Debian': {
      if $::operatingsystem == 'Ubuntu' {

        $default_default_runlevel = 3
        $template                 = undef

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
      case $::operatingsystemmajrelease {
        '10': {
          $default_default_runlevel = 3
          $template                 = 'inittab/suse10.erb'
        }
        '11': {
          $default_default_runlevel = 3
          $template                 = 'inittab/suse11.erb'
        }
        default: {
          fail("operatingsystemmajrelease is <${::operatingsystemmajrelease}> and inittab supports Suse versions 10 and 11.")
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

  if $template {
    $content = template($template)
  } else {
    $content = undef
  }

  if $::osfamily == 'Debian' and $::operatingsystem == 'Ubuntu' {
    file { 'rc-sysinit.override':
      ensure  => file,
      path    => '/etc/init/rc-sysinit.override',
      content => template('inittab/ubuntu.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  } else {
    file { 'inittab':
      ensure  => file,
      path    => '/etc/inittab',
      content => $content,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }
}
