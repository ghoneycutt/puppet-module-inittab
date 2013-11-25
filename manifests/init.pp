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
    'Redhat': {
      case $::lsbmajdistrelease {
        '5': {
          $default_default_runlevel = 3
          $template                 = 'inittab/el5.erb'
        }
        '6': {
          $default_default_runlevel = 3
          $template                 = 'inittab/el6.erb'
        }
        default: {
          fail("lsbmajdistrelease is <${::lsbmajdistrelease}> and inittab supports versions 5 and 6.")
        }
      }
    }
    'Debian': {
      if $::lsbdistid == 'Ubuntu' {

        $default_default_runlevel = 3
        $template                 = undef
        include inittab::ubuntu

      } else {
        case $::lsbmajdistrelease {
          '6': {
            $default_default_runlevel = 2
            $template                 = 'inittab/debian6.erb'
          }
          default: {
            fail("lsbmajdistrelease is <${::lsbmajdistrelease}> and inittab supports version 6.")
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
          fail("kernelrelease is <${::kernelrelease}> and inittab supports versions 5.10 and 5.11.")
        }
      }
    }
    'Suse':{
      case $::lsbmajdistrelease {
        '11': {
          $default_default_runlevel = 3
          $template                 = 'inittab/suse11.erb'
        }
        default: {
          fail("lsbmajdistrelease is <${::lsbmajdistrelease}> and inittab supports version 11.")
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

  file { 'inittab':
    ensure  => file,
    path    => '/etc/inittab',
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
