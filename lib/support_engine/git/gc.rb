# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling commits
    class Gc < Base
      class << self
        # Performs a cleaning of useless git data
        # @param path [String, Pathname] path to a place where git repo is
        # @return [Boolean] true if everything went fine
        # @raise [SupportEngine::Errors::FailedShellCommand] raised when anything went wrong
        # @example Cleanup current repo
        #   SupportEngine::Git::Gc.prune(Rails.root) #=> true
        def prune(path)
          result = SupportEngine::Shell.call_in_path(path, 'git gc --prune -q')
          fail_if_invalid(result)
          true
        end
      end
    end
  end
end
