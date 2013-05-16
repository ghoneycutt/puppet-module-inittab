# == Class: inittab::ubuntu
#
# Manage inittab on Ubuntu
#
class inittab::ubuntu inherits inittab {

  File ['inittab'] {
    ensure  => absent,
  }

  File ['rc-sysinit.override'] {
    content => template('inittab/ubuntu.erb'),
  }
}
