# frozen_string_literal: true

RSpec.describe SupportEngine::Git::Extras do
  describe '.effort' do
    subject(:effort) { described_class.effort(path, Time.zone.now - 1.month, 5) }

    let(:path) { SupportEngine::Git::RepoBuilder::MasterWithHistory.location }

    before { SupportEngine::Git::RepoBuilder::MasterWithHistory.bootstrap }
    after { SupportEngine::Git::RepoBuilder::MasterWithHistory.destroy }

    it { expect(effort).to be_a(Array) }
    it { expect(effort.first).to include('master.rb') }
    it { expect(effort.count).to eq(4) }
  end
end
