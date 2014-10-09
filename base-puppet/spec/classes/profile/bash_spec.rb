require 'spec_helper'

describe 'profile::bash' do
  it { is_expected.to contain_package 'bash' }
end
