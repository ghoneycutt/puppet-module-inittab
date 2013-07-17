# == Class: inittab::sled11
#
# Manage inittab on SuSE 11
#
class inittab::sled11 inherits inittab {

  File ['inittab'] {
    content => template('inittab/sled11.erb'),
  }
}
