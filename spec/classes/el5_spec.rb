require 'spec_helper'
describe 'inittab::el5' do

  describe 'EL5 systems' do
    let :facts do
      {:osfamily          => 'redhat',
       :lsbmajdistrelease => '5'
      }
    end

    it {
      should include_class('inittab')
    }

    it {
      should contain_file('inittab').with_content(/^id:3:initdefault:$/)
    }

    it {
      should contain_file('inittab').with_content(/^# Template for EL5$/)
    }
  end

end
