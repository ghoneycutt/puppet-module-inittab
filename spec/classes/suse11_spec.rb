require 'spec_helper'
describe 'inittab::suse11' do

  describe 'SuSE 11 systems' do
    let :facts do
      {:osfamily          => 'Suse',
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
      should contain_file('inittab').with_content(/SuSE Linux/)
    }
  end

end
