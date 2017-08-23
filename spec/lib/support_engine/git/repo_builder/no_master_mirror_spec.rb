# frozen_string_literal: true

RSpec.describe SupportEngine::Git::RepoBuilder::NoMasterMirror do
  describe '#bootstrap' do
    subject(:bootstrap) { described_class.bootstrap }

    before do
      expect(described_class).to receive(:destroy)
      expect(SupportEngine::Git).to receive(:clone_mirror)
        .with(
          SupportEngine::Git::RepoBuilder::NoMaster.location,
          described_class.location
        ) { 'test' }
    end

    it { expect(bootstrap).to eq('test') }
  end
end
