# frozen_string_literal: true

RSpec.describe_current do
  let(:committer_name) { 'Committer' }
  let(:committer_email) { 'committer@coditsu.io' }

  describe '.call' do
    subject(:call) { described_class.call }

    it { expect(call).to be_instance_of(String) }
    it { expect(call).to eq("#{committer_name} <#{committer_email}>") }
  end

  describe '.name' do
    subject(:name) { described_class.name }

    it { expect(name).to be_instance_of(String) }
    it { expect(name).to eq(committer_name) }
  end

  describe '.email' do
    subject(:email) { described_class.email }

    it { expect(email).to be_instance_of(String) }
    it { expect(email).to eq(committer_email) }
  end
end
