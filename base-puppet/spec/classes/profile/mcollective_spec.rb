require 'spec_helper'

describe 'profile::mcollective' do
  it { is_expected.to contain_class('mcollective').with(
    'connector' => 'rabbitmq',
    'factsource' => 'yaml',
    'classesfile' => '/var/lib/puppet/state/classes.txt',
  ) }

  context 'mcollective plugins' do
    [
      'puppet',
      'service',
      'package',
      'nettest',
      'filemgr',
      'iptables',
      'nrpe',
    ].each do |mco_plugin|
      it { is_expected.to contain_mcollective__plugin(mco_plugin).with_package(true) }
    end
  end
end
