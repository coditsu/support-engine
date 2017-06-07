# frozen_string_literal: true

RSpec.describe SupportEngine::Git::RepoBuilder do
  describe '.bootstrap' do
    subject(:bootstrap) { described_class.bootstrap }

    let(:version) { class_double(SupportEngine::Git::RepoBuilder::Master) }
    let(:versions) { [version] }

    before do
      expect(described_class).to receive(:versions) { versions }
      expect(version).to receive(:bootstrap)
    end

    it { bootstrap }
  end

  describe '.destroy' do
    subject(:destroy) { described_class.destroy }

    let(:version) { class_double(SupportEngine::Git::RepoBuilder::Master) }
    let(:versions) { [version] }

    before do
      expect(described_class).to receive(:versions) { versions }
      expect(version).to receive(:destroy)
    end

    it { destroy }
  end

  describe '.bare?' do
    subject(:bare?) { described_class.bare?(path) }

    context 'true' do
      let(:path) { SupportEngine::Git::RepoBuilder::MasterMirror.location }

      it { expect(bare?).to be true }
    end

    context 'false' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

      it { expect(bare?).to be false }
    end
  end

  describe '.checkout?' do
    subject(:checkout?) { described_class.checkout?(path, branch) }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    context 'already on branch' do
      let(:branch) { 'master' }

      it { expect(checkout?).to be true }
    end

    context 'switch to branch' do
      let(:branch) { 'different-branch' }

      after { described_class.checkout?(path, 'master') }

      it { expect(checkout?).to be true }
    end

    context 'branch not exists' do
      let(:branch) { 'not-existent' }

      it { expect(checkout?).to be false }
    end
  end

  describe '.checkout_success?' do
    subject(:checkout_success?) { described_class.send(:checkout_success?, message, branch) }

    let(:branch) { 'master' }

    context 'already on branch' do
      let(:message) { "Already on '#{branch}'" }

      it { expect(checkout_success?).to be true }
    end

    context 'switch to branch' do
      let(:message) { "Switched to branch '#{branch}'" }

      it { expect(checkout_success?).to be true }
    end

    context 'invalid message' do
      let(:message) { "error: pathspec 'not-existent' did not match any file(s) known to git." }

      it { expect(checkout_success?).to be false }
    end
  end

  describe '.versions' do
    subject(:versions) { described_class.send(:versions) }

    it { expect(versions.size).to eq(6) }
    it { expect(versions).to include(SupportEngine::Git::RepoBuilder::Master) }
    it { expect(versions).to include(SupportEngine::Git::RepoBuilder::MasterMirror) }
    it { expect(versions).to include(SupportEngine::Git::RepoBuilder::NoMaster) }
    it { expect(versions).to include(SupportEngine::Git::RepoBuilder::NoMasterMirror) }
    it { expect(versions).to include(SupportEngine::Git::RepoBuilder::BrokenHeadRef) }
    it { expect(versions).to include(SupportEngine::Git::RepoBuilder::BrokenHeadRefMirror) }
  end
end
