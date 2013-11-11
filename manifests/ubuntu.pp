# == Class: inittab::ubuntu
#
# Manage inittab on Ubuntu
#
class inittab::ubuntu inherits inittab {

  File ['inittab'] {
    ensure  => absent,
  }

  file { 'rc-sysinit.override':
    ensure  => file,
    path    => '/etc/init/rc-sysinit.override',
    content => template('inittab/ubuntu.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
