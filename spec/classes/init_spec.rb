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
      { :osfamily                   => 'RedHat',
        :operatingsystemmajrelease  => '6',
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
        { :osfamily                   => 'RedHat',
          :operatingsystemmajrelease  => '0',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/^operatingsystemmajrelease is <0> and inittab supports RedHat versions 5 and 6./)
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

  describe 'Ubuntu systems of the Debian family' do
    let :facts do
      { :osfamily  => 'Debian',
        :operatingsystem => 'Ubuntu',
      }
    end

    it { should contain_class('inittab::ubuntu') }
  end

  platforms = {
    'debian6' =>
      { :osfamily                   => 'Debian',
        :release                    => '6',
        :operatingsystemmajrelease  => '6',
      },
    'el5' =>
      { :osfamily                   => 'RedHat',
        :release                    => '5',
        :operatingsystemmajrelease  => '5',
      },
    'el5xenu' =>
      { :osfamily                   => 'RedHat',
        :release                    => '5',
        :operatingsystemmajrelease  => '5',
        :virtual                    => 'xenu',
      },
    'el6' =>
      { :osfamily                   => 'RedHat',
        :release                    => '6',
        :operatingsystemmajrelease  => '6',
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
end
