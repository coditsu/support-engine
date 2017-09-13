# frozen_string_literal: true

RSpec.describe SupportEngine::Git::Branch do
  let(:commits_scope) { SupportEngine::Git::Commits }
  let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

  describe '.commit' do
    subject(:branch) { described_class.commit(path, commit_hash) }

    let(:commit_hash) { SupportEngine::Git::Commits.all(path).first[:commit_hash] }

    context 'when path exist and git repo' do
      it { expect(branch).to eq 'different-branch' }
    end

    context 'when path exist but not git repo' do
      let(:path) { Pathname.new '/' }

      it { expect { branch }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { branch }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end
  end

  describe '.all' do
    subject(:all) { described_class.all(path) }

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { all }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path exist and git repo' do
      it { expect(all).to eq %w[different-branch master] }
    end
  end

  describe '.head' do
    subject(:head) { described_class.head(path) }

    it { expect(head).to eq 'master' }
  end

  describe '.originated_from' do
    subject { described_class.originated_from(path, branch, 'master') }

    let(:branch) { 'different-branch' }
    let(:commit_hash_originated_from) { commits_scope.all(path).last[:commit_hash] }

    context 'master with branch' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }
      let(:branch) { 'master' }
      let(:commit_hash) { commits_scope.all(path, branch: branch).first[:commit_hash] }

      before { SupportEngine::Git::RepoBuilder::Master.bootstrap }
      after { SupportEngine::Git::RepoBuilder::Master.bootstrap }

      it { is_expected.to eq(commit_hash) }
    end

    context 'master branch only' do
      let(:branch) { 'master' }
      let(:path) { SupportEngine::Git::RepoBuilder::MasterOnly.location }
      let(:commit_hash) { commits_scope.all(path, branch: branch).first[:commit_hash] }

      before { SupportEngine::Git::RepoBuilder::MasterOnly.bootstrap }
      after { SupportEngine::Git::RepoBuilder::MasterOnly.bootstrap }

      it { is_expected.to eq(commit_hash) }
    end

    context 'big branch' do
      let(:path) { SupportEngine::Git::RepoBuilder::MasterWithBigBranch.location }

      before { SupportEngine::Git::RepoBuilder::MasterWithBigBranch.bootstrap }
      after { SupportEngine::Git::RepoBuilder::MasterWithBigBranch.bootstrap }

      it { is_expected.to eq(commit_hash_originated_from) }
    end

    context 'big branch on cloned repository' do
      let(:path) { SupportEngine::Git::RepoBuilder::MasterWithBigBranchMirror.location }

      before { SupportEngine::Git::RepoBuilder::MasterWithBigBranchMirror.bootstrap }
      after { SupportEngine::Git::RepoBuilder::MasterWithBigBranchMirror.bootstrap }

      it { is_expected.to eq(commit_hash_originated_from) }
    end
  end
end
