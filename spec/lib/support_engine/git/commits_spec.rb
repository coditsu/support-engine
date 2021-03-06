# frozen_string_literal: true

RSpec.describe_current do
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

    context 'when we have branch with weird name' do
      let(:path) { SupportEngine::Git::RepoBuilder::MasterWithWeirdBranch.location }
      let(:commit) do
        SupportEngine::Shell.call_in_path(
          SupportEngine::Git::RepoBuilder::MasterWithWeirdBranch.location,
          'git log -1 --pretty="%H|%cD"'
        )[:stdout].split('|')
      end
      let(:commit_hash) { commit.first }
      let(:committed_at) { Time.zone.parse(commit.last.strip) }
      let(:single_commit) { all.find { |cm| cm[:commit_hash] == commit_hash } }

      before { SupportEngine::Git::RepoBuilder::MasterWithWeirdBranch.bootstrap }

      it { expect(single_commit).not_to be_nil }
      it { expect(single_commit[:committed_at]).to eq(committed_at) }
      it { expect(single_commit[:commit_hash]).to eq(commit_hash) }

      it 'expect to have a committed_at desc order' do
        expect(all[0][:committed_at]).to be > all[1][:committed_at]
      end
    end
  end

  describe '.latest_by_day' do
    subject(:latest_by_day) { described_class.latest_by_day(path, limit: limit) }

    let(:limit) { nil }

    context 'when path exist and git repo' do
      let(:path) { Pathname.new './' }
      let(:days_in_return_order) { latest_by_day.map { |commit| commit[:committed_at] } }
      let(:expected_hash) { '6774fb756c0d2a9773a471c362c687fde4973528' }

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

  describe '.pull_requests' do
    subject(:pull_requests) { described_class.pull_requests(path) }

    context 'when path exist and git repo' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

      it { expect { pull_requests.size }.not_to raise_error }
    end

    context 'when path exist but not git repo' do
      let(:path) { Pathname.new '/' }

      it { expect { pull_requests }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { pull_requests }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end
  end

  describe '.diff' do
    subject(:result) { described_class.diff(path, ref_a, ref_b) }

    # We check against ourselfs not example repos so we can actually check true constant hashes
    # that don't change with each spec execution
    let(:path) { SupportEngine.gem_root }

    context 'when ref a is ahead of ref b' do
      let(:ref_a) { 'd0a3d16e5a19bae700f113ff25095551dd74053d' }
      let(:ref_b) { '6774fb756c0d2a9773a471c362c687fde4973528' }

      it { is_expected.to eq [] }
    end

    context 'when ref a is equal to ref b' do
      let(:ref_a) { '6774fb756c0d2a9773a471c362c687fde4973528' }
      let(:ref_b) { '6774fb756c0d2a9773a471c362c687fde4973528' }

      it { is_expected.to eq [] }
    end

    context 'when ref b is ahead of ref a' do
      let(:ref_a) { '6774fb756c0d2a9773a471c362c687fde4973528' }
      let(:ref_b) { 'd0a3d16e5a19bae700f113ff25095551dd74053d' }
      let(:expected_commits) do
        %w[
          d0a3d16e5a19bae700f113ff25095551dd74053d
          a2b1f5828c8e5d7732af42aaaa024373ccb96873
        ]
      end

      it { is_expected.to eq expected_commits }
    end
  end
end
