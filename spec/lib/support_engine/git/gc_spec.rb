# frozen_string_literal: true

RSpec.describe_current do
  describe '#reset' do
    subject(:reset) { described_class.reset(path) }

    context 'when some files were introduced' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }
      let(:first_introduced_file) { rand.to_s }
      let(:second_introduced_file) { rand.to_s }
      let(:introduced) { SupportEngine::Git::Status.introduced(path) }

      before do
        `echo change >> #{File.join(path, first_introduced_file)}`
        `echo change >> #{File.join(path, second_introduced_file)}`
        reset
      end

      it { expect(introduced.size).to eq 0 }
    end

    context 'when path exist but not git repo' do
      let(:path) { Pathname.new '/' }

      it { expect { reset }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when path does not exist' do
      let(:path) { Pathname.new "/#{rand}" }

      it { expect { reset }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end
  end
end
