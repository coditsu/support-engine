# frozen_string_literal: true

RSpec.describe SupportEngine::Git::Commits do
  describe '.all' do
    subject(:all) { described_class.all(path) }

    context 'when path exist and git repo' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }
      let(:commit) do
        SupportEngine::Shell.call_in_path(
          SupportEngine::Git::RepoBuilder::Master.location,
          'git log -1 --pretty="%H|%cD"'
        )[:stdout].split('|')
      end
      let(:commit_hash) { commit.first }
      let(:committed_at) { Time.zone.parse(commit.last.strip) }
      let(:single_commit) { all.find { |cm| cm[:commit_hash] == commit_hash } }

      it { expect(single_commit).not_to be_nil }
      it { expect(single_commit[:committed_at]).to eq(committed_at) }
      it { expect(single_commit[:commit_hash]).to eq(commit_hash) }
      it 'expect to have a committed_at desc order' do
        expect(all[0][:committed_at]).to be > all[1][:committed_at]
      end
    end

    context 'when path exist but not git repo' do
      let(:path) { Pathname.new '/' }

      it { expect { all }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { all }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when we want limited number of commits by time' do
      # on local machines timezone is in CET and Time.zone.now returns UTC
      subject(:all) { described_class.all(path, since: since) }

      let(:since) { Time.zone.now + 6.hours }
      let(:path) { SupportEngine::Git::RepoBuilder::MasterMirror.location }

      # There won't be any commits from now
      it { expect(all.size).to eq(0) }
    end
  end

  describe '.latest_by_day' do
    subject(:latest_by_day) { described_class.latest_by_day(path, limit: limit) }

    let(:limit) { nil }

    context 'when path exist and git repo' do
      let(:path) { Pathname.new './' }
      let(:days_in_return_order) { latest_by_day.map { |commit| commit[:committed_at] } }
      let(:expected_hash) { '53647d2ec6ddf6dc51a8cd572aa1fb9c021d82ee' }

      it { expect(latest_by_day.last[:commit_hash]).to eq expected_hash }
      it 'expect to have a committed_at desc order' do
        # We compare to reverse because Ruby makes an asc sort
        expect(days_in_return_order).to eq days_in_return_order.sort.reverse
      end
    end

    context 'when path exist and git repo with liit' do
      let(:limit) { 1 }
      let(:path) { Pathname.new './' }
      let(:days_in_return_order) { latest_by_day.map { |commit| commit[:committed_at] } }
      let(:expected_hash) { '69168f7ad757f854a71873669ec6431359d27988' }

      it { expect(latest_by_day.count).to eq 1 }
    end

    context 'when path exist but not git repo' do
      let(:path) { Pathname.new '/' }

      it { expect { latest_by_day }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { latest_by_day }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end
  end

  describe '.latest_by_branch' do
    subject(:latest_by_branch) { described_class.latest_by_branch(path) }

    context 'when path exist and git repo' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

      it { expect(latest_by_branch.size).not_to eq 0 }
    end

    context 'when path exist but not git repo' do
      let(:path) { Pathname.new '/' }

      it { expect { latest_by_branch }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { latest_by_branch }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end
  end

  describe '.originated_from' do
    subject { described_class.originated_from(path, branch, commit_hash) }

    let(:branch) { 'different-branch' }
    let(:commit_hash) { described_class.all(path).first[:commit_hash] }
    let(:commit_hash_originated_from) { described_class.all(path).last[:commit_hash] }

    context 'master with branch' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }
      let(:branch) { 'master' }
      let(:commit_hash) { described_class.all(path, branch: branch).first[:commit_hash] }

      before { SupportEngine::Git::RepoBuilder::Master.bootstrap }
      after { SupportEngine::Git::RepoBuilder::Master.bootstrap }

      it { is_expected.to eq(commit_hash) }
    end

    context 'master branch only' do
      let(:branch) { 'master' }
      let(:path) { SupportEngine::Git::RepoBuilder::MasterOnly.location }
      let(:commit_hash) { described_class.all(path, branch: branch).first[:commit_hash] }

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
