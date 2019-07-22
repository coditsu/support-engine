# frozen_string_literal: true

RSpec.describe_current do
  describe '#introduced' do
    subject(:introduced) { described_class.introduced(path) }

    let(:path) { SupportEngine::Git::RepoBuilder::Master.location }

    before { SupportEngine::Git::Gc.reset(path) }

    after { SupportEngine::Git::Gc.reset(path) }

    context 'when no files were introduced' do
      it { is_expected.to eq [] }
    end

    context 'when some files were modified but not introduced' do
      before { `echo change >> #{File.join(path, 'master.rb')}` }

      it { is_expected.to eq [] }
    end

    context 'when some files were introduced' do
      let(:introduced_file_name1) { rand.to_s }
      let(:introduced_file_name2) { rand.to_s }

      before do
        `echo change >> #{File.join(path, introduced_file_name1)}`
        `echo change >> #{File.join(path, introduced_file_name2)}`
      end

      it { expect(introduced.size).to eq 2 }
      it { is_expected.to include introduced_file_name1 }
      it { is_expected.to include introduced_file_name2 }
    end

    context 'when some files were introduced and changed' do
      let(:introduced_file_name1) { rand.to_s }
      let(:introduced_file_name2) { rand.to_s }

      before do
        `echo change >> #{File.join(path, 'master.rb')}`
        `echo change >> #{File.join(path, introduced_file_name1)}`
        `echo change >> #{File.join(path, introduced_file_name2)}`
      end

      it { expect(introduced.size).to eq 2 }
      it { is_expected.to include introduced_file_name1 }
      it { is_expected.to include introduced_file_name2 }
    end
  end
end
