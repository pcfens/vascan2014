require 'spec_helper'

describe 'profile::puppet' do

  it { is_expected.to contain_package 'puppet' }
  it { is_expected.to contain_service 'puppet' }
  it { is_expected.to contain_augeas('remove_puppet_templatedir').with(
    'context' => '/files/etc/puppet/puppet.conf',
    'changes' => 'rm main/templatedir',
  ) }
  it { is_expected.to contain_augeas('set_puppet_server').with(
    'context' => '/files/etc/puppet/puppet.conf',
    'changes' => 'set main/server ip-10-0-0-10.ec2.internal',
  ) }

end
