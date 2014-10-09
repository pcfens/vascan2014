require 'spec_helper'

describe 'profile::firewall' do
  it { is_expected.to contain_class 'firewall' }

  context 'firewall rules' do
    [
      '000 accept icmp traffic',
      '001 accept ssh traffic',
      '002 accept local traffic',
      '003 accept established connections',
    ].each do |rule|
      it { is_expected.to contain_firewall(rule).with_action('accept') }
    end
  end

  it { is_expected.to contain_resources('firewall').with_purge(true) }
end
