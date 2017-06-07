# frozen_string_literal: true

RSpec.describe SupportEngine::Git::RepoBuilder::Master do
  describe 'BOOTSTRAP_CMD' do
    subject(:bootstrap) { described_class.bootstrap }

    before do
      expect(described_class).to receive(:destroy)
      expect(
        SupportEngine::Shell
      ).to receive(:call).with(described_class::BOOTSTRAP_CMD) { 'test' }
    end

    it { expect(bootstrap).to eq('test') }
  end
end
