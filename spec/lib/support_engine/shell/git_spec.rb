# frozen_string_literal: true

RSpec.describe_current do
  describe '#call_in_path' do
    subject(:shell_result) do
      described_class.call_in_path(path, command, options)
    end

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    context 'when we execute a valid shell command' do
      let(:command) { :shortlog }
      let(:options) { '-sn -e --all' }

      it 'expect to return array data' do
        expect(shell_result).to be_instance_of(Array)
        expect(shell_result).not_to be_empty
      end
    end

    context 'when we execute valid command with invalid options' do
      let(:command) { :shortlog }
      let(:options) { '-no-such-option' }

      it { expect { shell_result }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when we execute invalid command' do
      let(:command) { 'no-such-command' }
      let(:options) { '-no-such-option' }

      it { expect { shell_result }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end
  end
end
