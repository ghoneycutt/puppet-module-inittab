# == Class: inittab::el6
#
# Manage inittab on EL 6
#
class inittab::el6 inherits inittab {

  File ['inittab'] {
    content => template('inittab/el6.erb'),
  }
}
