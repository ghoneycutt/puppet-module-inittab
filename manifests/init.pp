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
    'Solaris': {
      case $::operatingsystemrelease {
        '5.11': {
          include inittab::sol11
        }
        default: {
          fail("operatingsystemrelease is <${::operatingsystemrelease}> and inittab supports versions 11.")
        }
      }
    }
    default: {
      fail("osfamily is <${::osfamily}> and inittab module supports RedHat and Ubuntu and Solaris.")
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
