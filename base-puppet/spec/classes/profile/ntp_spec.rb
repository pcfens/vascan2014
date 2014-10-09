require 'spec_helper'

describe 'profile::ntp' do
  it { is_expected.to contain_class 'ntp' }
end
