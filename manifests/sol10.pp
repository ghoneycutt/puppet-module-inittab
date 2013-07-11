# == Class: inittab::sol10
#
# Manage inittab on Solaris 10
#
class inittab::sol10 inherits inittab {

  File ['inittab'] {
    content => template('inittab/sol10.erb'),
  }
}
