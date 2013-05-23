require 'spec_helper'
describe 'inittab::el6' do

  describe 'EL6 systems' do
    let :facts do
      {:osfamily          => 'redhat',
       :lsbmajdistrelease => '6'
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
