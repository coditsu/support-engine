# frozen_string_literal: true

RSpec.describe SupportEngine::Git::RepoBuilder::Base do
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

    before do
      described_class.const_set(:BOOTSTRAP_CMD, command)
      expect(described_class).to receive(:destroy)
      expect(SupportEngine::Shell).to receive(:call).with(command) { 'test' }
    end

    it { expect(bootstrap).to eq('test') }
  end

  describe '.destroy' do
    subject(:destroy) { described_class.destroy }

    let(:path) { File.join(Dir.tmpdir, rand.to_s) }

    before { allow(described_class).to receive(:location) { path } }

    context 'dir exist' do
      before do
        FileUtils.mkdir_p(path)
        destroy
      end

      it { expect(Dir.exist?(path)).to be false }
    end

    context 'dir does not exist' do
      before { expect(FileUtils).not_to receive(:rm_r) }

      it { destroy }
    end
  end
end
