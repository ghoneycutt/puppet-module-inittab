# == Class: inittab::suse
#
# Manage inittab on Suse 11
#
class inittab::suse inherits inittab {

  File ['inittab'] {
    content => template('inittab/suse.erb'),
  }
}
