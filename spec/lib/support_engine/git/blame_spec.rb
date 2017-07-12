# frozen_string_literal: true

RSpec.describe SupportEngine::Git::Blame do
  describe '.all' do
    subject(:all) { described_class.all(path, 'master.rb') }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    it { expect(all).to be_a(Array) }
    it { expect(all.count).to eq(13) }
  end
end
