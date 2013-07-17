# == Class: inittab::sled10
#
# Manage inittab on SuSE 10
#
class inittab::sled10 inherits inittab {

  File ['inittab'] {
    content => template('inittab/sled10.erb'),
  }
}
