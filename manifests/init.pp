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
  $default_runlevel = '3',
) {

  # validate default_runlevel
  validate_re($default_runlevel, '^[0-6sS]$', "default_runlevel <${default_runlevel}> does not match regex")

  case $::osfamily {
    'redhat': {
      case $::lsbmajdistrelease {
        '5': {
          include inittab::el5
        }
        '6': {
          include inittab::el6
        }
        default: {
          fail("lsbmajdistrelease is <${::lsbmajdistrelease}> and inittab supports versions 5 and 6.")
        }
      }
    }
    'Debian': {
      case $::lsbdistid {
        'Ubuntu': {
          include inittab::ubuntu
        }
        default: {
          fail("lsbdistid is <${::lsbdistid}> and inittab supports Ubuntu.")
        }
      }

      file { 'rc-sysinit.override':
        ensure => file,
        path   => '/etc/init/rc-sysinit.override',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }
    }
    'Suse': {
      case $::operatingsystem{
        'SLED': {
          case $::lsbdistrelease {
            '10': {
              include inittab::sled10
            }
            '11': {
              include inittab::sled11
            }
            default: {
              fail("lsbdistrelease is <${::lsbdistrelease}> and inittab supports SLED 10&11.")
            }
          }
        }
        'SLES': {
          case $::lsbdistrelease {
            '10': {
              include inittab::sles10
            }
            '11': {
              include inittab::sles11
            }
            default: {
              fail("lsbdistrelease is <${::lsbdistrelease}> and inittab supports SLES 10&11.")
            }
          }
        }
        default: {
          fail("operatingsystem is <${::operatingsystem}> and inittab supports SLES and SLED.")
        }
      }
    }
    default: {
      fail("osfamily is <${::osfamily}> and inittab module supports RedHat and Ubuntu.")
    }
  }

  file { 'inittab':
    ensure => file,
    path   => '/etc/inittab',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
}
