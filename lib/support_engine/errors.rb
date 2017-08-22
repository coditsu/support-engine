# frozen_string_literal: true

module SupportEngine
  # Namespace for app errors
  module Errors
    # Base app error
    Base = Class.new(StandardError)
    # Raised when we try to execute a shell command
    # but for some reason it failed
    FailedShellCommand = Class.new(Base)
    # Raised when we cannot determine branch of a commit
    UnknownBranch = Class.new(Base)
    # Raised when we are not able to determinate from which commit branch originated from
    UnableToDetermineOriginatedFrom = Class.new(Base)
  end
end
