# == Class: inittab::suse11
#
# Manage inittab on SuSE 11
#
class inittab::suse11 inherits inittab {

  File ['inittab'] {
    content => template('inittab/suse11.erb'),
  }
}
