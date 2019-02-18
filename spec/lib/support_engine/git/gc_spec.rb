# frozen_string_literal: true

RSpec.describe SupportEngine::Git::Gc do
  describe '.prune' do
    subject(:prune) { described_class.prune(path) }

    context 'when path exist and git repo' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

      it { expect(prune).to eq true }
    end

    context 'when path exist but not git repo' do
      let(:path) { Pathname.new '/' }

      it { expect { prune }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { prune }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end
  end
end
