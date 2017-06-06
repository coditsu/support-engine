# frozen_string_literal: true

RSpec.describe SupportEngine::Errors do
  specify do
    expect(described_class::Base.ancestors).to include(StandardError)
  end

  specify do
    expect(described_class::FailedShellCommand.ancestors).to include(described_class::Base)
  end
end
