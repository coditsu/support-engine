# frozen_string_literal: true

RSpec.describe SupportEngine::Git::Ref do
  describe '#latest' do
    subject(:latest) { described_class.latest(path) }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    it { expect(latest).to eq('refs/heads/different-branch') }
  end

  describe '#head' do
    subject(:head) { described_class.head(path) }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    context 'when it runs and we get the result' do
      it { expect(head).to be_instance_of(Hash) }
      it { expect(head).to have_key(:stdout) }
      it { expect(head).to have_key(:stderr) }
      it { expect(head).to have_key(:exit_code) }
      it { expect(head).to eq(stdout: "master\n", stderr: '', exit_code: 0) }
    end

    context 'when raise_on_invalid_exit true by default' do
      let(:path) { SupportEngine::Git::RepoBuilder::BrokenHeadRef.location }

      it { expect { head }.to raise_error(SupportEngine::Errors::FailedShellCommand) }
    end

    context 'when raise_on_invalid_exit false' do
      subject(:head) { described_class.head(path, false) }

      let(:path) { SupportEngine::Git::RepoBuilder::BrokenHeadRef.location }

      it { expect { head }.not_to raise_error }
      it { expect(head).to be_instance_of(Hash) }
      it { expect(head).to have_key(:stdout) }
      it { expect(head).to have_key(:stderr) }
      it { expect(head).to have_key(:exit_code) }
      it { expect(head[:stdout]).to eq("HEAD\n") }
      it { expect(head[:stderr]).to include("fatal: ambiguous argument 'HEAD'") }
      it { expect(head[:exit_code]).to eq(128) }
    end
  end

  describe '#head!' do
    subject(:head!) { described_class.head!(path) }

    context 'when valid head ref' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

      it { expect(head!).to eq('master') }
    end

    context 'when broken head ref' do
      let(:path) { File.join(SupportEngine.gem_root, 'tmp', rand.to_s) }
      let(:dest) { SupportEngine::Git::RepoBuilder::BrokenHeadRef.location }

      before { SupportEngine::Git.clone_mirror(dest, path) }
      after { FileUtils.rm_rf(path) }

      it { expect(head!).to eq('develop') }
    end
  end

  describe '#head?' do
    subject(:head?) { described_class.head?(described_class.head(path, false)) }

    context 'when valid head ref' do
      let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

      it { expect(head?).to be true }
    end

    context 'when broken head ref' do
      let(:path) { SupportEngine::Git::RepoBuilder::BrokenHeadRef.location }

      it { expect(head?).to be false }
    end
  end
end
