# frozen_string_literal: true

RSpec.describe_current do
  describe '.bootstrap' do
    subject(:bootstrap) { described_class.bootstrap }

    let(:version) { class_double(SupportEngine::Git::RepoBuilder::Master) }
    let(:versions) { [version] }

    it 'expect to take all the versions and bootstrap all of them' do
      allow(described_class).to receive(:versions).and_return(versions)
      allow(version).to receive(:bootstrap)
      bootstrap
      expect(described_class).to have_received(:versions)
      expect(version).to have_received(:bootstrap)
    end
  end

  describe '.destroy' do
    subject(:destroy) { described_class.destroy }

    let(:version) { class_double(SupportEngine::Git::RepoBuilder::Master) }
    let(:versions) { [version] }

    it 'expect to take all the versions and destroy all of them' do
      allow(described_class).to receive(:versions).and_return(versions)
      allow(version).to receive(:destroy)
      destroy
      expect(described_class).to have_received(:versions)
      expect(version).to have_received(:destroy)
    end
  end

  describe '.bare?' do
    subject(:bare?) { described_class.bare?(path) }

    context 'when bare repo' do
      let(:path) { SupportEngine::Git::RepoBuilder::MasterBareMirror.location }

      before { SupportEngine::Git::RepoBuilder::MasterBareMirror.bootstrap }

      after { SupportEngine::Git::RepoBuilder::MasterBareMirror.destroy }

      it { expect(bare?).to be true }
    end

    context 'when not bare repo' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

      it { expect(bare?).to be false }
    end
  end

  describe '.versions' do
    subject(:versions) { described_class.send(:versions) }

    it { expect(versions.size).to eq(18) }
  end
end
