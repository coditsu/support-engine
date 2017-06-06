# frozen_string_literal: true

RSpec.describe SupportEngine do
  subject(:support_engine) { described_class }

  describe '#gem_root' do
    it 'expect to point to root of the gem' do
      expect(support_engine.gem_root).to eq(File.expand_path('../../..', __FILE__))
    end
  end
end
