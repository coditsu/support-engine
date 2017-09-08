# frozen_string_literal: true

RSpec.describe SupportEngine::Shell::Utf8 do
  describe '#call' do
    subject(:shell_result) do
      described_class.call(command_with_options, options)
    end

    let(:command_with_options) { 'ls' }
    let(:options) { { raise_on_invalid_exit: true } }

    it 'expect to run shell and encode' do
      expect(SupportEngine::Shell).to receive(:call).with(command_with_options, options) { true }
      expect(described_class).to receive(:encode).with(true)
      shell_result
    end
  end

  describe '#call_in_path' do
    subject(:shell_result) do
      described_class.call_in_path(path, command_with_options, options)
    end

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }
    let(:command_with_options) { 'ls' }
    let(:options) { { raise_on_invalid_exit: true } }
    let(:shell_args) { [path, command_with_options, options] }

    it 'expect to call shell in path and encode' do
      expect(SupportEngine::Shell).to receive(:call_in_path).with(*shell_args) { true }
      expect(described_class).to receive(:encode).with(true)
      shell_result
    end
  end

  describe '#encode' do
    subject(:encoded_result) { described_class.send(:encode, result) }

    let(:result) do
      {
        stdout: 'stdout'.encode('ASCII-8BIT'),
        stderr: 'stderr'.encode('ASCII-8BIT'),
        exit_code: 0
      }
    end

    it { expect(encoded_result[:stdout].encoding).to eq(Encoding::UTF_8) }
    it { expect(encoded_result[:stderr].encoding).to eq(Encoding::UTF_8) }
  end
end
