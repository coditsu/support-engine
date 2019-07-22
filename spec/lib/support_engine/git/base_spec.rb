# frozen_string_literal: true

RSpec.describe_current do
  describe '.fail_if_invalid' do
    subject(:flow) { described_class.send(:fail_if_invalid, result) }

    context 'when exit code is not zero' do
      let(:result) { { exit_code: 1 } }

      it { expect { flow }.to raise_error SupportEngine::Errors::FailedShellCommand }
    end

    context 'when we try to do something not in a git repo' do
      let(:result) { { exit_code: 0, stderr: 'Not a git repository' } }

      it { expect { flow }.to raise_error SupportEngine::Errors::FailedShellCommand }
    end

    context 'when everything was ok' do
      let(:result) { { exit_code: 0, stderr: '' } }

      it { expect { flow }.not_to raise_error }
    end
  end
end
