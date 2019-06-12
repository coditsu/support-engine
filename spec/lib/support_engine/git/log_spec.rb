# frozen_string_literal: true

RSpec.describe SupportEngine::Git::Log do
  let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

  before { SupportEngine::Git::RepoBuilder::MasterMultipleCommitters.bootstrap }

  after { SupportEngine::Git::RepoBuilder::MasterMultipleCommitters.destroy }

  describe '.shortlog' do
    subject(:shortlog) { described_class.shortlog(path) }

    it { expect(shortlog).to be_a(Array) }

    context 'when one committer' do
      it { expect(shortlog.count).to eq(1) }
    end

    context 'when three committers' do
      let(:path) { SupportEngine::Git::RepoBuilder::MasterMultipleCommitters.location }

      it { expect(shortlog.count).to eq(3) }
      it do
        expect(
          shortlog.any? { |v| v.include?(SupportEngine::Git::RepoBuilder::Committer.email) }
        ).to be true
      end
      it { expect(shortlog.any? { |v| v.include?('committer2@coditsu.io') }).to be true }
      it { expect(shortlog.any? { |v| v.include?('committer3@coditsu.io') }).to be true }
    end
  end

  describe '.file_last_committer' do
    subject(:file_last_committer) { described_class.file_last_committer(path, 'master.rb') }

    let(:path) { SupportEngine::Git::RepoBuilder::MasterMultipleCommitters.location }

    it { expect(file_last_committer).to be_a(Array) }

    # we expect at least 5 elements
    # commit, author, date, empty line, commit message, ..., ...
    it { expect(file_last_committer.count).to be >= 5 }

    it { expect(file_last_committer[1]).to include('committer3@coditsu.io') }
  end

  describe '.shortstat' do
    subject(:shortstat) { described_class.shortstat(path) }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    it { expect(shortstat).to be_a(Array) }
    it { expect(shortstat.first).to include('master commit') }
    it { expect(shortstat.last).to include('1 file changed, 1 insertion(+)') }
  end

  describe '.head_committed_at' do
    subject(:head_committed_at) { described_class.head_committed_at(path) }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    it { expect(head_committed_at).to be_a(Time) }
  end
end
