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
          expect(SupportEngine::Git::RepoBuilder.checkout?(dest, 'different-branch')).to be true
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
          expect(SupportEngine::Git::RepoBuilder.checkout?(dest, 'different-branch')).to be true
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
          expect(SupportEngine::Git::RepoBuilder.checkout?(dest, 'different-branch')).to be true
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

  describe '#commits' do
    subject(:commits) { described_class.commits(path) }

    context 'when path exist and git repo' do
      let(:path) { Pathname.new './' }

      it { expect { commits }.not_to raise_error }
      it { expect(commits['2017-06-06']).to eq '53647d2ec6ddf6dc51a8cd572aa1fb9c021d82ee' }
    end

    context 'when path exist but not git repo' do
      let(:path) { Pathname.new '/' }

      it { expect { commits }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { commits }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end
  end
end
