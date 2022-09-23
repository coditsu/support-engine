# frozen_string_literal: true

RSpec.describe_current do
  let(:instance) { described_class.new }

  describe '#measure' do
    subject(:measure) { instance.measure { sleep(0.01) } }

    it { is_expected.to be_a(Array) }
    it { expect(measure).to eq([0, 11]) }
  end
end
