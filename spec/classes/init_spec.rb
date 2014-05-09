require 'spec_helper'
describe 'inittab' do

  describe 'with parameter default_runlevel' do
    %w{ 0 1 2 3 4 5 6 s S }.each do |runlevel|
      context "set to #{runlevel}" do
        it "should not fail on runlevel #{runlevel}" do
          expect { runlevel }.to_not raise_error
        end
      end
    end
  end

  describe 'with default_runlevel set to invalid value' do
    let(:params) { { :default_runlevel => '10' } }
    let :facts do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.5',
      }
    end

    it 'should fail' do
      expect {
        should contain_class('inittab')
      }.to raise_error(Puppet::Error,/^default_runlevel <10> does not match regex/)
    end
  end

  describe 'with unsupported' do
    context 'version of osfamily RedHat' do
      let :facts do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '0',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/^operatingsystemrelease is <0> and inittab supports RedHat versions 5 and 6./)
      end
    end

    context 'version of osfamily Debian' do
      let :facts do
        { :osfamily                   => 'Debian',
          :operatingsystem            => 'NotUbuntu',
          :operatingsystemmajrelease  => '23',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/operatingsystemmajrelease is <23> and inittab supports Debian version 6./)
      end
    end

    context 'osfamily' do
      let(:facts) { { :osfamily => 'UNSUPPORTED' } }

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/osfamily is <UNSUPPORTED> and inittab module supports Debian, RedHat, Ubuntu, Suse, and Solaris./)
      end
    end
  end

  describe 'with default values for parameters on Ubuntu' do
    inittab_fixture = File.read(fixtures("ubuntu.rc-sysinit.override"))
    let :facts do
      { :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
      }
    end

    it { should contain_class('inittab') }

    it { should_not contain_file('inittab')  }

    it {
      should contain_file('rc-sysinit.override').with({
        :ensure  => 'file',
        :path    => '/etc/init/rc-sysinit.override',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
        })
    }

    it { should contain_file('rc-sysinit.override').with_content(inittab_fixture) }
end

  platforms = {

    'debian6' =>
      { :osfamily                   => 'Debian',
        :release                    => '6',
        :operatingsystemmajrelease  => '6',
      },
    'el5' =>
      { :osfamily               => 'RedHat',
        :release                => '5',
        :operatingsystemrelease => '5.9',
      },
    'el5xenu' =>
      { :osfamily               => 'RedHat',
        :release                => '5',
        :operatingsystemrelease => '5.9',
        :virtual                => 'xenu',
      },
    'el6' =>
      { :osfamily               => 'RedHat',
        :release                => '6',
        :operatingsystemrelease => '6.5',
      },
    'solaris10' =>
      { :osfamily      => 'Solaris',
        :release       => '10',
        :kernelrelease => '5.10',
      },
    'solaris11' =>
      { :osfamily      => 'Solaris',
        :release       => '11',
        :kernelrelease => '5.11',
      },
    'suse10' =>
      { :osfamily                   => 'Suse',
        :release                    => '10',
        :operatingsystemrelease     => '10.4',
      },
    'suse11' =>
      { :osfamily                   => 'Suse',
        :release                    => '11',
        :operatingsystemrelease     => '11.3',
      },
  }

  describe 'with default values for parameters on' do
    platforms.sort.each do |k,v|
      inittab_fixture = File.read(fixtures("#{k}.inittab"))
      context "#{v[:osfamily]} #{v[:release]}" do
        let :facts do
          { :osfamily                   => v[:osfamily],
            :operatingsystemrelease     => v[:operatingsystemrelease],
            :operatingsystemmajrelease  => v[:operatingsystemmajrelease],
            :kernelrelease              => v[:kernelrelease],
            :virtual                    => v[:virtual],
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

        it { should contain_file('inittab').with_content(inittab_fixture) }
      end
    end
  end

  describe 'ttys1 service and file for EL6' do
    context 'with ensure_ttys1 set to present' do
      let(:params) { { :ensure_ttys1 => 'present' } }
      let :facts do
        { :osfamily               => 'RedHat',
          :release                => '6',
          :operatingsystemrelease => '6.5',
        }
      end

      it {
        should contain_file('ttys1_conf').with({
          'ensure' => 'present',
          'source' => 'puppet:///modules/inittab/ttyS1.conf',
          'path'   => '/etc/init/ttyS1.conf',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      }

      it {
        should contain_service('ttyS1').with({
          'ensure'     => 'running',
          'hasstatus'  => 'false',
          'hasrestart' => 'false',
          'start'      => '/sbin/initctl start ttyS1',
          'stop'       => '/sbin/initctl stop ttyS1',
          'status'     => '/sbin/initctl status ttyS1 | grep ^"ttyS1 start/running" 1>/dev/null 2>&1',
          'require'    => 'File[ttys1_conf]',
        })
      }
    end

    context 'with ensure_ttys1 set to absent' do
      let(:params) { { :ensure_ttys1 => 'absent' } }
      let :facts do
        { :osfamily               => 'RedHat',
          :release                => '6',
          :operatingsystemrelease => '6.5',
        }
      end

      it {
        should contain_file('ttys1_conf').with({
          'ensure' => 'absent',
          'source' => 'puppet:///modules/inittab/ttyS1.conf',
          'path'   => '/etc/init/ttyS1.conf',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      }

      it { should_not contain_service('ttyS1') }
    end

    context 'with ensure_ttys1 undefined' do
      let :facts do
        { :osfamily               => 'RedHat',
          :release                => '6',
          :operatingsystemrelease => '6.5',
        }
      end

      it { should_not contain_file('ttys1_conf') }

      it { should_not contain_service('ttyS1') }
    end

    context 'with ensure_ttys1 set to an invalid value' do
      let(:params) { { :ensure_ttys1 => 'invalid' } }
      let :facts do
        { :osfamily               => 'RedHat',
          :release                => '6',
          :operatingsystemrelease => '6.5',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/^inittab::ensure_ttys1 is invalid and if defined must be \'present\' or \'absent\'./)
      end
    end
  end
end
