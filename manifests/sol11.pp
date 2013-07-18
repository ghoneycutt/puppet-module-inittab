# == Class: inittab::sol11
#
# Manage inittab on Solaris 11
#
class inittab::sol11 inherits inittab {

  File ['inittab'] {
    content => template('inittab/sol11.erb'),
  }
}
