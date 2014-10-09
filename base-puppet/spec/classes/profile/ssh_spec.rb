require 'spec_helper'

describe 'profile::ssh' do

  it { is_expected.to contain_class('ssh::server').with(
    'storeconfigs_enabled' => false,
    'options'              => {
      'PermitRootLogin' => 'no',
    }
  ) }
end
