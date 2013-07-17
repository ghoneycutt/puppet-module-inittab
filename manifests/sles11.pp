# == Class: inittab::sles11
#
# Manage inittab on SuSE 11
#
class inittab::sles11 inherits inittab {

  File ['inittab'] {
    content => template('inittab/sles11.erb'),
  }
}
