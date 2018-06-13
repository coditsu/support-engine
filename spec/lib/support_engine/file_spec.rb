# frozen_string_literal: true

RSpec.describe SupportEngine::File do
  describe '#encoding' do
    subject(:file_encoding) { described_class.encoding(path) }

    let(:path) { File.join(SupportEngine::Git::RepoBuilder::Master.location, 'master.rb') }

    it { expect(file_encoding).to eq('us-ascii') }

    context 'when file name includes weird characters' do
      let(:path) { 'weird () - $%^&*file.rb' }

      it 'expect to work without problems' do
        expect(file_encoding).to eq('utf-8')
      end
    end
  end
end
