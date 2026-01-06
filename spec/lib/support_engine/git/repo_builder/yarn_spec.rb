# frozen_string_literal: true

RSpec.describe_current do
  describe '.bootstrap_cmd' do
    subject(:bootstrap) { described_class.bootstrap }

    let(:shell_args) { described_class.bootstrap_cmd }

    it 'expect to remove previous repo, build new and return path to it' do
      allow(described_class).to receive(:destroy)
      allow(SupportEngine::Shell).to receive(:call).with(shell_args).and_return('test')
      expect(bootstrap).to eq('test')
      expect(described_class).to have_received(:destroy)
      expect(SupportEngine::Shell).to have_received(:call).with(shell_args)
    end
  end
end
