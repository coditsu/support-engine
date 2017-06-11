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

  describe '.blame' do
    subject(:blame) { described_class.blame(path, 'master.rb') }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    it { expect(blame).to be_a(Array) }
    it { expect(blame.count).to eq(13) }
  end

  describe '.blame_line' do
    subject(:blame_line) { described_class.blame_line(path, 'master.rb', 1) }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    it { expect(blame_line).to be_a(Array) }
    it { expect(blame_line.count).to eq(12) }
  end
end
