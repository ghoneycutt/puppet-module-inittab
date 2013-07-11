require 'spec_helper'
describe 'inittab' do

  describe 'Parameter default_runlevel ' do
    %w{ 0 1 2 3 4 5 6 s S }.each do |runlevel|
      it "should not fail on runlevel #{runlevel}" do
        expect { runlevel }.to_not raise_error(/default_runlevel <#{runlevel}> does not match regex/)
      end
    end

    let :params do
      {:default_runlevel => '10' }
    end

    it 'should fail on runlevel 10' do#{
      expect { subject }.to raise_error(/default_runlevel <10> does not match regex/)
    end#}
  end

  describe 'EL family systems version 5.*' do
    let :facts do
      {:osfamily          => 'redhat',
       :lsbmajdistrelease => '5'
      }
    end

    it {
      should include_class('inittab::el5')
    }
  end

  describe 'EL family systems version 6.*' do
    let :facts do
      {:osfamily          => 'redhat',
      :lsbmajdistrelease  => '6'
      }
    end

    it {
      should include_class('inittab::el6')
    }
  end

  describe 'EL family systems of unsupported version' do
    let :facts do
      {:osfamily          => 'redhat',
       :lsbmajdistrelease => '0'
      }
    end

    it {
      expect { subject }.to raise_error(/lsbmajdistrelease is <0> and inittab supports versions 5 and 6./)
    }
  end

  describe 'Suse family systems version 11.*' do
    let :facts do
      {:osfamily          => 'suse',
      :lsbmajdistrelease  => '11'
      }
    end

    it {
      should include_class('inittab::suse')
    }
  end


  describe 'Debian family systems' do
    let :facts do
      {:osfamily  => 'debian',
       :lsbdistid => 'ubuntu'
      }
    end

    it {
      should contain_file('rc-sysinit.override').with(
        :ensure => 'file',
        :path   => '/etc/init/rc-sysinit.override',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644'
    )
    }
  end

  describe 'Ubuntu systems of the Debian family' do
    let :facts do
      {:osfamily  => 'debian',
       :lsbdistid => 'ubuntu'
      }
    end

    it {
      should include_class('inittab::ubuntu')
    }
  end

  describe 'Debian family systems of unsupported version' do
    let :facts do
      {:osfamily  => 'debian',
       :lsbdistid => 'UNSUPPORTED'
      }
    end

    it {
      expect { subject }.to raise_error(/lsbdistid is <UNSUPPORTED> and inittab supports Ubuntu./)
    }
  end

  describe 'Unsupported systems' do
    let :facts do
      {:osfamily  => 'UNSUPPORTED'}
    end

    it {
      expect { subject }.to raise_error(/osfamily is <UNSUPPORTED> and inittab module supports RedHat and Ubuntu./)
    }
  end

  describe 'inittab should be managed for supported OS' do
    let :facts do
      {:osfamily          => 'redhat',
       :lsbmajdistrelease => '6'
      }
    end

    it {
      should contain_file('inittab').with(
        :ensure  => 'file',
        :path    => '/etc/inittab',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644'
      )
    }
  end

end
