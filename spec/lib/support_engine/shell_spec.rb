# frozen_string_literal: true

RSpec.describe SupportEngine::Shell do
  describe '#call' do
    subject(:shell_result) do
      described_class.call(
        command_with_options,
        raise_on_invalid_exit: raise_on_invalid_exit
      )
    end

    let(:raise_on_invalid_exit) { true }

    context 'when we execute a valid shell command' do
      let(:command_with_options) { 'ls' }

      it 'expect to return a proper hash with data' do
        expect(shell_result[:stdout]).to include('Gemfile')
        expect(shell_result[:stderr]).to be_empty
        expect(shell_result[:exit_code]).to eq(0)
      end
    end

    context 'when we execute valid command with invalid options' do
      let(:command_with_options) { 'ls -no-such-option' }

      context 'when raise_on_invalid_exit true' do
        it { expect { shell_result }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
      end

      context 'when raise_on_invalid_exit false' do
        let(:raise_on_invalid_exit) { false }

        it 'expect to return a proper hash with errors' do
          expect(shell_result[:stdout]).not_to include('Gemfile')
          expect(shell_result[:stderr]).not_to be_empty
          expect(shell_result[:exit_code]).not_to eq(0)
        end
      end
    end

    context 'when we execute invalid command' do
      let(:command_with_options) { 'no-such-command -x' }

      it 'expect to raise not catched error' do
        expect { shell_result }.to raise_error(Errno::ENOENT)
      end
    end
  end

  describe '#call_in_path' do
    subject(:shell_result) { described_class.call_in_path(path, 'ls') }

    let(:path) { File.join(SupportEngine.gem_root, 'tmp', rand.to_s) }
    let(:file) { rand.to_s }

    before do
      FileUtils.mkdir_p(path)
      FileUtils.touch(File.join(path, file))
    end

    it 'expect to return a proper hash with data' do
      expect(shell_result[:stdout]).to include(file)
      expect(shell_result[:stderr]).to be_empty
      expect(shell_result[:exit_code]).to eq(0)
    end
  end

  describe '.escape' do
    context 'when string is safe' do
      [rand.to_s, 'random-words', 'nothing_special'].each do |string|
        it { expect(described_class.escape(string)).to eq(string) }
      end
    end

    context 'when we have unsafe data' do
      {
        'rm -rf' => 'rm\\ -rf',
        'tada dada' => 'tada\\ dada'
      }.each do |unsafe, safe|
        it { expect(described_class.escape(unsafe)).to eq(safe) }
      end
    end
  end
end
