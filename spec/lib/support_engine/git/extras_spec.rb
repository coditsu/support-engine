# frozen_string_literal: true

RSpec.describe SupportEngine::Git::Extras do
  describe '.effort' do
    subject(:effort) { described_class.effort(path, Time.zone.now - 1.month, 5) }

    let(:path) { SupportEngine.gem_root }

    it { expect(effort).to be_a(Array) }
    it { expect(effort.first).to include('lib/support_engine/git/repo_builder/base.rb') }
    it { expect(effort.count).to eq(6) }
  end
end
