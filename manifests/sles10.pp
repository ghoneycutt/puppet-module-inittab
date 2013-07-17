# == Class: inittab::el5
#
# Manage inittab on EL 6
#
class inittab::sles10 inherits inittab {

  File ['inittab'] {
    content => template('inittab/sles10.erb'),
  }
}
