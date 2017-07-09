# frozen_string_literal: true

RSpec.describe SupportEngine::Git::RepoBuilder::MasterWithHistory do
  describe 'BOOTSTRAP_CMD' do
    subject(:bootstrap) { described_class.bootstrap }

    after { described_class.destroy }

    it { expect { bootstrap }.not_to raise_error }
  end
end
