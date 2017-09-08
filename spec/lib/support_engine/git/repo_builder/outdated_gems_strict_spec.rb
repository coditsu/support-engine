# frozen_string_literal: true

RSpec.describe SupportEngine::Git::RepoBuilder::OutdatedGemsStrict do
  describe 'BOOTSTRAP_CMD' do
    subject(:bootstrap) { described_class.bootstrap }

    let(:shell_args) { described_class::BOOTSTRAP_CMD }

    it 'expect to remove previous repo, build new and return path to it' do
      expect(described_class).to receive(:destroy)
      expect(SupportEngine::Shell).to receive(:call).with(shell_args).and_return('test')
      expect(bootstrap).to eq('test')
    end
  end
end
