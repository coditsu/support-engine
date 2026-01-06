# frozen_string_literal: true

RSpec.describe_current do
  describe '.bootstrap_cmd' do
    subject(:bootstrap) { described_class.bootstrap }

    after { described_class.destroy }

    it { expect { bootstrap }.not_to raise_error }
  end
end
