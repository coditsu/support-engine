# frozen_string_literal: true

RSpec.describe SupportEngine::File do
  describe '#encoding' do
    subject(:file_encoding) { described_class.encoding(path) }

    let(:path) { File.join(SupportEngine::Git::RepoBuilder::Master.location, 'master.rb') }

    it { expect(file_encoding).to eq('us-ascii') }
  end
end
