require 'spec_helper'
describe 'inittab' do

  describe 'Parameter default_runlevel ' do
    %w{ 0 1 2 3 4 5 6 s S }.each do |runlevel|
      it "should not fail on runlevel #{runlevel}" do
        expect { runlevel }.to_not raise_error
      end
    end
  end

  describe 'default_runlevel set to invalid value' do
    let(:params) { { :default_runlevel => '10' } }
    let :facts do
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    it 'should fail' do
      expect {
        should contain_class('inittab')
      }.to raise_error(Puppet::Error,/default_runlevel <10> does not match regex/)
    end
  end

  describe 'EL family systems of unsupported version' do
    let :facts do
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '0',
      }
    end

    it 'should fail' do
      expect {
        should contain_class('inittab')
      }.to raise_error(Puppet::Error,/lsbmajdistrelease is <0> and inittab supports versions 5 and 6./)
    end
  end

  describe 'Ubuntu systems of the Debian family' do
    let :facts do
      { :osfamily  => 'Debian',
        :lsbdistid => 'Ubuntu',
      }
    end

    it { should contain_class('inittab::ubuntu') }
  end

  describe 'Debian family systems of unsupported version' do
    let :facts do
      { :osfamily          => 'Debian',
        :lsbdistid         => 'NotUbuntu',
        :lsbmajdistrelease => '23',
      }
    end

    it 'should fail' do
      expect {
        should contain_class('inittab')
      }.to raise_error(Puppet::Error,/lsbmajdistrelease is <23> and inittab supports version 6./)
    end
  end

  describe 'Unsupported osfamily' do
    let(:facts) { { :osfamily => 'UNSUPPORTED' } }

    it 'should fail' do
      expect {
        should contain_class('inittab')
      }.to raise_error(Puppet::Error,/osfamily is <UNSUPPORTED> and inittab module supports Debian, RedHat, Ubuntu, Suse, and Solaris./)
    end
  end

  describe 'Debian 6 (squeeze) systems' do
    let :facts do
      { :osfamily          => 'Debian',
        :lsbdistid         => 'Debian',
        :lsbmajdistrelease => '6',
      }
    end

    it { should contain_class('inittab') }

    it { should_not contain_file('rc-sysinit.override')  }

    it {
      should contain_file('inittab').with({
        :ensure  => 'file',
        :path    => '/etc/inittab',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
      })
    }

    it { should contain_file('inittab').with_content(/^id:2:initdefault:$/) }
  end

  describe 'EL5 systems' do
    let :facts do
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '5',
      }
    end

    it { should contain_class('inittab') }

    it {
      should contain_file('inittab').with({
        :ensure  => 'file',
        :path    => '/etc/inittab',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
      })
    }

    it { should contain_file('inittab').with_content(/^id:3:initdefault:$/) }

    it { should contain_file('inittab').with_content(/^# Template for EL5$/) }
  end

  describe 'EL6 systems' do
    let :facts do
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    it { should contain_class('inittab') }

    it {
      should contain_file('inittab').with({
        :ensure  => 'file',
        :path    => '/etc/inittab',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
      })
    }

    it { should contain_file('inittab').with_content(/^id:3:initdefault:$/) }

    it { should contain_file('inittab').with_content(/^# Template for EL6$/) }
  end

  describe 'Solaris 10 systems' do
    let :facts do
      { :osfamily      => 'Solaris',
        :kernelrelease => '5.10',
      }
    end

    it { should contain_class('inittab') }

    it {
      should contain_file('inittab').with({
        :ensure  => 'file',
        :path    => '/etc/inittab',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
      })
    }

    it { should contain_file('inittab').with_content(/^# Template for Solaris 10$/) }
  end

  describe 'Solaris 11 systems' do
    let :facts do
      { :osfamily      => 'Solaris',
        :kernelrelease => '5.11',
      }
    end

    it { should contain_class('inittab') }

    it {
      should contain_file('inittab').with({
        :ensure  => 'file',
        :path    => '/etc/inittab',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
      })
    }

    it { should contain_file('inittab').with_content(/^# Template for Solaris 11$/) }
  end

  describe 'SuSE 11 systems' do
    let :facts do
      { :osfamily          => 'Suse',
        :lsbmajdistrelease => '11',
      }
    end

    it { should contain_class('inittab') }

    it {
      should contain_file('inittab').with({
        :ensure  => 'file',
        :path    => '/etc/inittab',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
      })
    }

    it { should contain_file('inittab').with_content(/^id:3:initdefault:$/) }

    it { should contain_file('inittab').with_content(/SuSE Linux/) }
  end
end
