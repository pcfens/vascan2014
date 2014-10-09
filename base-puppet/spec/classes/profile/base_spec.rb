require 'spec_helper'

describe 'profile::base' do
  it { is_expected.to contain_class 'profile::bash' }
  it { is_expected.to contain_class 'profile::mcollective' }
  it { is_expected.to contain_class 'profile::puppet' }
  it { is_expected.to contain_class 'profile::firewall' }
  it { is_expected.to contain_class 'profile::ntp' }
  it { is_expected.to contain_class 'profile::ssh' }
end
