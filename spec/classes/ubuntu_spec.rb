require 'spec_helper'
describe 'inittab::ubuntu' do

  describe 'Ubuntu systems' do
    let :facts do
      { :osfamily  => 'Debian',
        :lsbdistid => 'Ubuntu',
      }
    end

    it { should include_class('inittab') }

    it {
      should contain_file('inittab').with({
        :ensure => 'absent',
      })
    }

    it {
      should contain_file('rc-sysinit.override').with({
        'ensure' => 'file',
        'path'   => '/etc/init/rc-sysinit.override',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
    }

    it { should contain_file('rc-sysinit.override').with_content(/^env DEFAULT_RUNLEVEL=3$/) }
  end
end
