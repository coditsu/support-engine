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

    context 'when we want limited number of commits' do
      # on local machines timezone is in CET and Time.zone.now returns UTC
      subject(:all) { described_class.all(path, Time.zone.now + 6.hours) }

      let(:path) { SupportEngine::Git::RepoBuilder::MasterMirror.location }

      # There won't be any commits from now
      it { expect(all.size).to eq(0) }
    end
  end

  describe '.latest_by_day' do
    subject(:latest_by_day) { described_class.latest_by_day(path) }

    context 'when path exist and git repo' do
      let(:path) { Pathname.new './' }
      let(:days_in_return_order) { latest_by_day.keys.map { |day| Date.parse(day) } }

      it { expect(latest_by_day['2017-06-06']).to eq '53647d2ec6ddf6dc51a8cd572aa1fb9c021d82ee' }
      it 'expect to have a committed_at desc order' do
        # We compare to reverse because Ruby makes an asc sort
        expect(days_in_return_order).to eq days_in_return_order.sort.reverse
      end
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
end
