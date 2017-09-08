# frozen_string_literal: true

RSpec.describe SupportEngine::Git::RepoBuilder do
  describe '.bootstrap' do
    subject(:bootstrap) { described_class.bootstrap }

    let(:version) { class_double(SupportEngine::Git::RepoBuilder::Master) }
    let(:versions) { [version] }

    it 'expect to take all the versions and bootstrap all of them' do
      expect(described_class).to receive(:versions) { versions }
      expect(version).to receive(:bootstrap)
      bootstrap
    end
  end

  describe '.destroy' do
    subject(:destroy) { described_class.destroy }

    let(:version) { class_double(SupportEngine::Git::RepoBuilder::Master) }
    let(:versions) { [version] }

    it 'expect to take all the versions and destroy all of them' do
      expect(described_class).to receive(:versions) { versions }
      expect(version).to receive(:destroy)
      destroy
    end
  end

  describe '.bare?' do
    subject(:bare?) { described_class.bare?(path) }

    context 'true' do
      let(:path) { SupportEngine::Git::RepoBuilder::MasterBareMirror.location }

      before { SupportEngine::Git::RepoBuilder::MasterBareMirror.bootstrap }
      after { SupportEngine::Git::RepoBuilder::MasterBareMirror.destroy }

      it { expect(bare?).to be true }
    end

    context 'false' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

      it { expect(bare?).to be false }
    end
  end

  describe '.versions' do
    subject(:versions) { described_class.send(:versions) }

    it { expect(versions.size).to eq(17) }
  end
end
