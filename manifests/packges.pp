# ## Class:  pkg_solaris ##
#
# Manage solaris packages path
#
# ### Parameters ###
#
#
class  packages 
{
  package { 'sudo':
    provider  => 'sun',
    adminfile => template('packages/solaris.erb'),
    ensure    => latest,
  }
  package { 'VMware Tools':
    provider          => 'vmware',
    ensure            => absent,
    uninstall_options =>  [{'REMOVE' => 'Sync,VSS' }]
}
