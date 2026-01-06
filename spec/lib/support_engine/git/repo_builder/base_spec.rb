# frozen_string_literal: true

RSpec.describe_current do
  describe '.location' do
    subject(:location) { described_class.location }

    it { expect(location).to be_instance_of(String) }
  end

  describe '.location_git' do
    subject(:location_git) { described_class.location_git }

    it { expect(location_git).to be_instance_of(String) }
    it { expect(location_git).to include('.git') }
  end

  describe '.name' do
    subject(:name) { described_class.name }

    it { expect(name).to be_instance_of(String) }
    it { expect(name).to eq('base') }
  end

  describe '.origin' do
    subject(:origin) { described_class.origin }

    it { expect(origin).to be_instance_of(String) }
    it { expect(origin).to eq('https://something.origin/base') }
  end

  describe '.bootstrap' do
    subject(:bootstrap) { described_class.bootstrap }

    let(:command) { 'command' }

    before { allow(described_class).to receive(:bootstrap_cmd).and_return(command) }

    it 'expect to call, destroy and match shell result' do
      allow(described_class).to receive(:destroy)
      allow(SupportEngine::Shell).to receive(:call).with(command).and_return('test')
      expect(bootstrap).to eq('test')
      expect(described_class).to have_received(:destroy)
      expect(SupportEngine::Shell).to have_received(:call).with(command)
    end
  end

  describe '.destroy' do
    subject(:destroy) { described_class.destroy }

    let(:path) { File.join(Dir.tmpdir, rand.to_s) }

    before { allow(described_class).to receive(:location) { path } }

    context 'when dir exist' do
      before do
        FileUtils.mkdir_p(path)
        destroy
      end

      it { expect(Dir.exist?(path)).to be false }
    end

    context 'when dir does not exist' do
      it 'expect not to try to remove it' do
        expect(FileUtils).not_to receive(:rm_r)
        destroy
      end
    end
  end
end
