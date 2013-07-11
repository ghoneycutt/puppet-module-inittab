require 'spec_helper'
describe 'inittab::sol10' do

  describe 'Sol10 systems' do
    let :facts do
      {:osfamily      => 'Solaris',
       :kernelrelease => '5.10'
      }
    end

    it {
      should include_class('inittab')
    }

    it {
      should contain_file('inittab').with_content(/^# Template for Solaris 10$/)
    }
  end

end
