# frozen_string_literal: true

RSpec.describe_current do
  describe '#bootstrap' do
    subject(:bootstrap) { described_class.bootstrap }

    let(:clone_args) do
      [
        SupportEngine::Git::RepoBuilder::NoMaster.location,
        described_class.location
      ]
    end

    it 'expect to remove previous repo, clone mirror to a new one and return clone path' do
      allow(described_class).to receive(:destroy)
      allow(SupportEngine::Git).to receive(:clone_mirror).with(*clone_args).and_return('test')
      expect(bootstrap).to eq('test')
      expect(described_class).to have_received(:destroy)
      expect(SupportEngine::Git).to have_received(:clone_mirror).with(*clone_args)
    end
  end
end
