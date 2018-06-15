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
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '6.5',
      }
    end

    it 'should fail' do
      expect {
        should contain_class('inittab')
      }.to raise_error(Puppet::Error,/default_runlevel <10> does not match regex/)
    end
  end

  describe 'with file_mode specified' do
    context 'as a valid mode' do
      let(:params) { { :file_mode => '0600' } }
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
        }
      end

      it {
        should contain_file('inittab').with({
          :ensure  => 'file',
          :path    => '/etc/inittab',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0600',
        })
      }
    end

    [true,'666','66666'].each do |mode|
      context "as invalid mode #{mode}" do
        let(:params) { { :file_mode => mode } }

        it 'should fail' do
          expect {
            should contain_class('inittab')
          }.to raise_error(Puppet::Error,/inittab::file_mode is <#{mode}> and must be a valid four digit mode in octal notation\./)
        end
      end
    end
  end

  describe 'with parameter require_single_user_mode_password' do
    [true,'true',false,'false'].each do |value|
      context "set to #{value}" do
        let(:params) { { :require_single_user_mode_password => value } }
        let(:facts) do
          {
            :osfamily               => 'RedHat',
            :release                => '5',
            :operatingsystem        => 'RedHat',
            :operatingsystemrelease => '5.8',
          }
        end

        if value.to_s == 'true'
          it { should contain_file('inittab').with_content(/^\s*~~:S:wait:\/sbin\/sulogin$/) }
        end

        if value.to_s == 'false'
          it { should contain_file('inittab').without_content(/^\s*~~:S:wait:\/sbin\/sulogin$/) }
        end
      end
    end

    context 'set to a non-boolean' do
      let(:params) { { :require_single_user_mode_password => 'invalid' } }
      let :facts do
        { :osfamily               => 'RedHat',
          :release                => '5',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '5.8',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/Unknown type of boolean/)
      end
    end
  end

  describe 'with ctrlaltdel_override_path specified' do
    context 'as a valid path' do
      let(:params) do
        {
          :ctrlaltdel_override_path => '/path/to/control-alt-delete.override',
          :enable_ctrlaltdel        => false,
        }
      end
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
        }
      end

      it {
        should contain_file('ctrlaltdel_override').with({
          :ensure => 'file',
          :path   => '/path/to/control-alt-delete.override',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644',
        })
      }
    end

    context 'as an invalid path' do
      let(:params) do
        {
          :ctrlaltdel_override_path => 'invalid/path',
          :enable_ctrlaltdel        => false,
        }
      end
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/"invalid\/path" is not an absolute path/)
      end
    end

    context 'as an invalid type' do
      let(:params) do
        {
          :ctrlaltdel_override_path => true,
          :enable_ctrlaltdel        => false,
        }
      end
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/true is not an absolute path/)
      end
    end
  end

  describe 'with ctrlaltdel_override_owner specified' do
    context 'as a valid string with enable_ctrlaltdel set to true' do
      let(:params) do
        {
          :ctrlaltdel_override_owner => 'gh',
          :enable_ctrlaltdel         => false,
        }
      end
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
        }
      end

      it {
        should contain_file('ctrlaltdel_override').with({
          :ensure => 'file',
          :path   => '/etc/init/control-alt-delete.override',
          :owner  => 'gh',
          :group  => 'root',
          :mode   => '0644',
        })
      }
    end

    context 'as an invalid type (non-string)' do
      let(:params) { { :ctrlaltdel_override_owner => ['invalid','type'] } }
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/\["invalid", "type"\] is not a string/)
      end
    end
  end

  describe 'with ctrlaltdel_override_group specified' do
    context 'as a valid string with enable_ctrlaltdel set to true' do
      let(:params) do
        {
          :ctrlaltdel_override_group => 'gh',
          :enable_ctrlaltdel         => false,
        }
      end
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
        }
      end

      it {
        should contain_file('ctrlaltdel_override').with({
          :ensure => 'file',
          :path   => '/etc/init/control-alt-delete.override',
          :owner  => 'root',
          :group  => 'gh',
          :mode   => '0644',
        })
      }
    end

    context 'as an invalid type (non-string)' do
      let(:params) { { :ctrlaltdel_override_group => ['invalid','type'] } }
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/\["invalid", "type"\] is not a string/)
      end
    end
  end

  describe 'with ctrlaltdel_override_mode specified' do
    context 'as a valid mode' do
      let(:params) do
        {
          :ctrlaltdel_override_mode => '0600',
          :enable_ctrlaltdel        => false,
        }
      end
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6',
        }
      end

      it {
        should contain_file('ctrlaltdel_override').with({
          :ensure => 'file',
          :path   => '/etc/init/control-alt-delete.override',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0600',
        })
      }
    end

    [true,'666','66666'].each do |mode|
      context "as invalid mode #{mode}" do
        let(:params) do
          {
            :ctrlaltdel_override_mode => mode,
            :enable_ctrlaltdel        => false,
          }
        end

        it 'should fail' do
          expect {
            should contain_class('inittab')
          }.to raise_error(Puppet::Error,/inittab::ctrlaltdel_override_mode is <#{mode}> and must be a valid four digit mode in octal notation\./)
        end
      end
    end
  end

  describe 'with unsupported' do
    context 'version of osfamily RedHat' do
      let :facts do
        { :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '0',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/operatingsystemrelease is <0> and inittab supports RedHat versions 5, 6 and 7\./)
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
        }.to raise_error(Puppet::Error,/operatingsystemmajrelease is <23> and inittab supports Debian version 6\./)
      end
    end

    context 'osfamily' do
      let(:facts) { { :osfamily => 'UNSUPPORTED' } }

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/osfamily is <UNSUPPORTED> and inittab module supports Debian, RedHat, Ubuntu, Suse and Solaris\./)
      end
    end
  end

  describe 'with default values for parameters on Ubuntu' do
    inittab_fixture = File.read(fixtures('ubuntu.rc-sysinit.override'))
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

    it { should_not contain_file('ctrlaltdel_override') }
end

  platforms = {

    'debian6' =>
      { :osfamily                    => 'Debian',
        :release                     => '6',
        :operatingsystem             => 'Debian',
        :operatingsystemmajrelease   => '6',
        :support_ctrlaltdel_override => 'false',
        :systemd                     => false,
      },
    'el5' =>
      { :osfamily                    => 'RedHat',
        :release                     => '5',
        :operatingsystem             => 'RedHat',
        :operatingsystemrelease      => '5.9',
        :support_ctrlaltdel_override => 'false',
        :systemd                     => false,
      },
    'el5xenu' =>
      { :osfamily                    => 'RedHat',
        :release                     => '5',
        :operatingsystem             => 'RedHat',
        :operatingsystemrelease      => '5.9',
        :virtual                     => 'xenu',
        :support_ctrlaltdel_override => 'false',
        :systemd                     => false,
      },
    'el6' =>
      { :osfamily                    => 'RedHat',
        :release                     => '6',
        :operatingsystem             => 'RedHat',
        :operatingsystemrelease      => '6.5',
        :support_ctrlaltdel_override => 'true',
        :systemd                     => false,
      },
    'el7' =>
      { :osfamily                    => 'RedHat',
        :release                     => '7',
        :operatingsystem             => 'RedHat',
        :operatingsystemrelease      => '7.0',
        :support_ctrlaltdel_override => 'false',
        :systemd                     => true,
      },
    'solaris10' =>
      { :osfamily                    => 'Solaris',
        :release                     => '10',
        :operatingsystem             => 'Solaris',
        :kernelrelease               => '5.10',
        :support_ctrlaltdel_override => 'false',
        :systemd                     => false,
      },
    'solaris11' =>
      { :osfamily                    => 'Solaris',
        :release                     => '11',
        :operatingsystem             => 'Solaris',
        :kernelrelease               => '5.11',
        :support_ctrlaltdel_override => 'false',
        :systemd                     => false,
      },
    'suse10' =>
      { :osfamily                    => 'Suse',
        :release                     => '10',
        :operatingsystem             => 'Suse',
        :operatingsystemrelease      => '10.4',
        :support_ctrlaltdel_override => 'false',
        :systemd                     => false,
      },
    'suse11' =>
      { :osfamily                    => 'Suse',
        :release                     => '11',
        :operatingsystem             => 'Suse',
        :operatingsystemrelease      => '11.3',
        :support_ctrlaltdel_override => 'false',
        :systemd                     => false,
      },
    'suse12' =>
      { :osfamily               => 'Suse',
        :release                => '12',
        :operatingsystem        => 'Suse',
        :operatingsystemrelease => '12.2',
        :systemd                => false,
      },
  }

  describe 'with values for parameters left at their default values' do
    [true,'true',false,'false'].each do |enable_ctrlaltdel_value|
      context "except for enable_ctrlaltdel which is set to #{enable_ctrlaltdel_value}" do
        platforms.sort.each do |k,v|
          inittab_fixture = File.read(fixtures("#{k}.inittab"))
          context "#{v[:osfamily]} #{v[:release]}" do
            ctrlaltdel_override_fixture = File.read(fixtures('control-alt-delete.override'))
            let(:params) { { :enable_ctrlaltdel => enable_ctrlaltdel_value } }
            let :facts do
              { :osfamily                  => v[:osfamily],
                :operatingsystem           => v[:operatingsystem],
                :operatingsystemrelease    => v[:operatingsystemrelease],
                :operatingsystemmajrelease => v[:operatingsystemmajrelease],
                :kernelrelease             => v[:kernelrelease],
                :virtual                   => v[:virtual],
              }
            end

            it { should compile.with_all_deps }

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

            if v[:support_ctrlaltdel_override].to_s == 'true' and enable_ctrlaltdel_value.to_s == 'false'
              it {
                should contain_file('ctrlaltdel_override').with({
                  :ensure => 'file',
                  :path   => '/etc/init/control-alt-delete.override',
                  :owner  => 'root',
                  :group  => 'root',
                  :mode   => '0644',
                })
              }

              it { should contain_file('inittab').with_content(inittab_fixture) }

              it { should contain_file('ctrlaltdel_override').with_content(ctrlaltdel_override_fixture) }
            end

            if v[:support_ctrlaltdel_override].to_s == 'true' and enable_ctrlaltdel_value.to_s == 'true'
              it {
                should contain_file('ctrlaltdel_override').with({
                  :ensure => 'absent',
                  :path   => '/etc/init/control-alt-delete.override',
                })
              }

              it { should contain_file('inittab').without_content(/^\s*ca/) }
            end

            if v[:support_ctrlaltdel_override].to_s == 'false' and enable_ctrlaltdel_value.to_s == 'true' and v[:osfamily] != 'Solaris'

              it { should contain_file('inittab').with_content(inittab_fixture) }

              it { should_not contain_file('ctrlaltdel_override') }
            end

            if v[:support_ctrlaltdel_override].to_s == 'false' and enable_ctrlaltdel_value.to_s == 'false'

              it { should_not contain_file('ctrlaltdel_override') }

              it { should contain_file('inittab').without_content(/^\s*ca/) }
            end

            if v[:systemd] == true
              it { should_not contain_file('ctrlaltdel_override') }

              it do
                should contain_file('/etc/systemd/system/default.target').with({
                  :ensure => 'link',
                  :target => '/lib/systemd/system/multi-user.target',
                })
              end

              if enable_ctrlaltdel_value.to_s == 'true'
                ctrlaltdel_target = '/lib/systemd/system/ctrl-alt-del.target'
              else
                ctrlaltdel_target = '/dev/null'
              end

              it do
                should contain_file('/etc/systemd/system/ctrl-alt-del.target').with({
                  :ensure => 'link',
                  :target => ctrlaltdel_target,
                })
              end
            else
              it { should_not contain_file('/etc/systemd/system/ctrl-alt-del.target') }
            end
          end
        end
      end
    end
  end

  describe 'ttys1 service and file for EL6' do
    context 'with ensure_ttys1 set to present' do
      let(:params) { { :ensure_ttys1 => 'present' } }
      let :facts do
        { :osfamily               => 'RedHat',
          :release                => '6',
          :operatingsystem        => 'RedHat',
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
          :operatingsystem        => 'RedHat',
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
          :operatingsystem        => 'RedHat',
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
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6.5',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/inittab::ensure_ttys1 is invalid and if defined must be \'present\' or \'absent\'\./)
      end
    end
  end

  describe 'with parameter enable_ctrlaltdel' do
    ['true',true].each do |value|
      context "set to #{value}" do
        let(:params) { { :enable_ctrlaltdel => value } }
        let :facts do
          { :osfamily               => 'RedHat',
            :release                => '6',
            :operatingsystem        => 'RedHat',
            :operatingsystemrelease => '6.5',
          }
        end

      end
    end

    context 'set to a non-boolean' do
      let(:params) { { :enable_ctrlaltdel => 'invalid' } }
      let :facts do
        { :osfamily               => 'RedHat',
          :release                => '6',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '6.5',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/Unknown type of boolean/)
      end
    end
  end

  describe 'with ctrlaltdelburstaction specified' do
    context 'set to a valid value' do
      let(:params) do
        {
          :ctrlaltdelburstaction => 'none',
        }
      end
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '7',
        }
      end

      it {
        should contain_file_line('CtrlAltDelBurstAction').with({
          :line => "CtrlAltDelBurstAction=#{params[:ctrlaltdelburstaction]}",
        })
      }
    end

    context 'set to an invalid value' do
      let(:params) do
        {
          :ctrlaltdelburstaction => 'invalid-value',
        }
      end
      let(:facts) do
        {
          :osfamily               => 'RedHat',
          :operatingsystem        => 'RedHat',
          :operatingsystemrelease => '7',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('inittab')
        }.to raise_error(Puppet::Error,/inittab::ctrlaltdelburstaction is #{params[:ctrlaltdelburstaction]} and if defined must be/)
      end
    end
  end
end
