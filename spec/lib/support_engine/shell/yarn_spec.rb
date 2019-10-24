# frozen_string_literal: true

RSpec.describe_current do
  describe '#call' do
    subject(:shell_result) { described_class.call(command, options) }

    let(:command) { 'cloc' }
    let(:options) { '--yaml' }
    let(:args) do
      [
         "yarn run --silent #{command} #{options}",
         raise_on_invalid_exit: true
      ]
    end

    it 'expect to run yarn in shell' do
      expect(SupportEngine::Shell::Utf8).to receive(:call).with(*args)
      shell_result
    end
  end

  describe '#call_in_path' do
    subject(:shell_result) do
      described_class.call_in_path(path, command, options)
    end

    before { SupportEngine::Git::RepoBuilder::Yarn.bootstrap }

    after { SupportEngine::Git::RepoBuilder::Yarn.destroy }

    let(:path) { SupportEngine::Git::RepoBuilder::Yarn.location }
    let(:command) { 'cloc' }
    let(:options) { "--yaml --quiet --progress-rate=0 #{path}" }

    it 'expect to return a proper hash with data' do
      expect(shell_result[:stdout]).not_to be_empty
      expect(shell_result[:stderr]).to be_empty
      expect(shell_result[:exit_code]).to eq(0)
    end
  end
end
