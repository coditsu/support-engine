# frozen_string_literal: true

RSpec.describe_current do
  specify do
    expect(described_class::Base.ancestors).to include(StandardError)
  end

  specify do
    expect(described_class::FailedShellCommand.ancestors).to include(described_class::Base)
  end

  specify do
    expect(described_class::UnknownBranch.ancestors).to include(described_class::Base)
  end
end
