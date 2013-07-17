# == Class: inittab::sles10
#
# Manage inittab on SuSE 10
#
class inittab::sles10 inherits inittab {

  File ['inittab'] {
    content => template('inittab/sles10.erb'),
  }
}
