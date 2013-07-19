require 'spec_helper'
describe 'inittab::sol11' do

  describe 'Sol11 systems' do
    let :facts do
      {
        :osfamily      => 'Solaris',
        :kernelrelease => '5.11',
      }
    end

    it {
      should include_class('inittab')
    }

    it {
      should contain_file('inittab').with_content(/^# Template for Solaris 11$/)
    }
  end
end
