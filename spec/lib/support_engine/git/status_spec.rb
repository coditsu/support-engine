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
      let(:first_introduced_file) { rand.to_s }
      let(:second_introduced_file) { rand.to_s }

      before do
        `echo change >> #{File.join(path, first_introduced_file)}`
        `echo change >> #{File.join(path, second_introduced_file)}`
      end

      it { expect(introduced.size).to eq 2 }
      it { is_expected.to include first_introduced_file }
      it { is_expected.to include second_introduced_file }
    end

    context 'when some files were introduced and changed' do
      let(:first_introduced_file) { rand.to_s }
      let(:second_introduced_file) { rand.to_s }

      before do
        `echo change >> #{File.join(path, 'master.rb')}`
        `echo change >> #{File.join(path, first_introduced_file)}`
        `echo change >> #{File.join(path, second_introduced_file)}`
      end

      it { expect(introduced.size).to eq 2 }
      it { is_expected.to include first_introduced_file }
      it { is_expected.to include second_introduced_file }
    end
  end
end
