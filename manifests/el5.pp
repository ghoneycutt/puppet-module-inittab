# == Class: inittab::el5
#
# Manage inittab on EL 6
#
class inittab::el5 inherits inittab {

  File ['inittab'] {
    content => template('inittab/el5.erb'),
  }
}
