# frozen_string_literal: true

RSpec.describe_current do
  subject(:support_engine) { described_class }

  describe '#gem_root' do
    it 'expect to point to root of the gem' do
      expect(support_engine.gem_root).to eq(File.expand_path('../..', __dir__))
    end
  end
end
