# frozen_string_literal: true

RSpec.describe SupportEngine::Git::Branch do
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

  describe '.head' do
    subject(:head) { described_class.head(path) }

    it { expect(head).to eq 'master' }
  end
end
