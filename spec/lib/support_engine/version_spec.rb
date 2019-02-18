# frozen_string_literal: true

RSpec.describe SupportEngine do
  describe 'VERSION' do
    it { expect(described_class.const_defined?('VERSION')).to be true }
    it { expect(described_class::VERSION).to be_instance_of(String) }
  end
end
