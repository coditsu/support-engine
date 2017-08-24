# frozen_string_literal: true

RSpec.describe SupportEngine::Git do
  describe '#clone_mirror' do
    subject(:clone_mirror) { described_class.clone_mirror(path, dest) }

    let(:dest) { File.join(SupportEngine.gem_root, 'tmp', rand.to_s) }

    after { FileUtils.rm_rf(dest) }

    context 'when path exist and git repo with master branch' do
      let(:path) { SupportEngine::Git::RepoBuilder::MasterMirror.location }

      context 'should clone without errors' do
        it { expect { clone_mirror }.not_to raise_error }
        it { expect(clone_mirror).to be true }
      end

      context 'check if we cloned properly' do
        before { clone_mirror }

        it { expect(SupportEngine::Git::RepoBuilder.bare?(dest)).to be false }
        it do
          expect(SupportEngine::Git.checkout(dest, 'different-branch')).to be true
        end
      end
    end

    context 'when path exist and git repo with no master branch' do
      let(:path) { SupportEngine::Git::RepoBuilder::NoMasterMirror.location }

      context 'should clone without errors' do
        it { expect { clone_mirror }.not_to raise_error }
        it { expect(clone_mirror).to be true }
      end

      context 'check if we cloned properly' do
        before { clone_mirror }

        it { expect(SupportEngine::Git::RepoBuilder.bare?(dest)).to be false }
        it do
          expect(SupportEngine::Git.checkout(dest, 'different-branch')).to be true
        end
      end
    end

    context 'when path exist and git repo with broken head ref' do
      let(:path) { SupportEngine::Git::RepoBuilder::BrokenHeadRefMirror.location }

      context 'should clone without errors' do
        it { expect { clone_mirror }.not_to raise_error }
        it { expect(clone_mirror).to be true }
      end

      context 'check if we cloned properly' do
        before { clone_mirror }

        it { expect(SupportEngine::Git::RepoBuilder.bare?(dest)).to be false }
        it do
          expect(SupportEngine::Git.checkout(dest, 'different-branch')).to be true
        end
      end
    end

    context 'when path exist but not git repo' do
      let(:path) { Pathname.new '/' }

      it { expect { clone_mirror }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { clone_mirror }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end
  end

  describe '.tracked_files_count' do
    subject(:tracked_files_count) { described_class.tracked_files_count(path) }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    it { expect(tracked_files_count).to be_a(Integer) }
    it { expect(tracked_files_count).to eq(1) }
  end

  describe '.checkout' do
    subject { described_class.checkout(path, ref) }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    context 'already on a branch' do
      let(:ref) { 'master' }

      it { is_expected.to be true }
    end

    context 'switch to abranch' do
      let(:ref) { 'different-branch' }

      after { described_class.checkout(path, 'master') }

      it { is_expected.to be true }
    end

    context 'switch to a commit hash' do
      let(:ref) { SupportEngine::Git::Commits.all(path).last[:commit_hash] }

      after { described_class.checkout(path, 'master') }

      it { is_expected.to be true }
    end

    context 'branch not exists' do
      let(:ref) { 'not-existent' }

      it { is_expected.to be false }
    end
  end

  describe '.checkout_success?' do
    subject { described_class.send(:checkout_success?, message, ref) }

    let(:ref) { 'master' }

    context 'already on branch' do
      let(:message) { "Already on '#{ref}'" }

      it { is_expected.to be true }
    end

    context 'switch to branch' do
      let(:message) { "Switched to branch '#{ref}'" }

      it { is_expected.to be true }
    end

    context 'switch to commit' do
      let(:ref) { '7987d360dc73ac64ead4a26f8a451822e37788f5' }
      let(:message) do
        "Note: checking out '7987d360dc73ac64ead4a26f8a451822e37788f5'.\n\n" \
        "You are in 'detached HEAD' state. You can look around, make experimental\n" \
        "changes and commit them, and you can discard any commits you make in this\n" \
        "state without impacting any branches by performing another checkout.\n\n" \
        "If you want to create a new branch to retain commits you create, you may\n" \
        "do so (now or later) by using -b with the checkout command again. Example:\n\n  " \
        "git checkout -b <new-branch-name>\n\nHEAD is now at 7987d36... master commit"
      end

      it { is_expected.to be true }
    end

    context 'invalid message' do
      let(:message) { "error: pathspec 'not-existent' did not match any file(s) known to git." }

      it { is_expected.to be false }
    end
  end
end
