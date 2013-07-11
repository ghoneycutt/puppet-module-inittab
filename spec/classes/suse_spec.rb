require 'spec_helper'
describe 'inittab::suse' do

  describe 'Suse systems' do
    let :facts do
      {:osfamily          => 'suse',
       :lsbmajdistrelease => '11'
      }
    end

    it {
      should include_class('inittab')
    }

    it {
      should contain_file('inittab').with_content(/^id:3:initdefault:$/)
    }

    it {
      should contain_file('inittab').with_content(/^# Template for EL6$/)
    }
  end

end
