require 'spec_helper'
describe 'crossbar' do

  context 'with default values for all parameters' do
    it { should contain_class('crossbar') }
  end
end
