# frozen_string_literal: true

RSpec.describe_current do
  let(:instance) { described_class.new }

  describe '#measure' do
    subject(:measure) { instance.measure { sleep(0.5) } }

    it { is_expected.to be_a(Array) }
    it { expect(measure[0]).to be_a(Numeric) }
    it { expect(measure[1]).to be_within(500).of(500) }
  end
end
