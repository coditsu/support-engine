# frozen_string_literal: true

RSpec.describe SupportEngine::Git::RepoBuilder::NoMasterMirror do
  describe '#bootstrap' do
    subject(:bootstrap) { described_class.bootstrap }

    let(:clone_mirror_args) do
      [
        SupportEngine::Git::RepoBuilder::NoMaster.location,
        described_class.location
      ]
    end

    it 'expect to remove previous repo, clone mirror to a new one and return clone path' do
      expect(described_class).to receive(:destroy)
      expect(SupportEngine::Git).to receive(:clone_mirror).with(*clone_mirror_args) { 'test' }
      expect(bootstrap).to eq('test')
    end
  end
end
