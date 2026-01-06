# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling GC and cleaning things
    class Gc < Base
      class << self
        # Resets the repo by cleaning all changed files and removing all untracked once
        # @param path [String, Pathname] path to a place where git repo is
        # @return [Boolean] true if everything went fine
        # @raise [SupportEngine::Errors::FailedShellCommand] raised when anything went wrong
        # @example Reset state (watch out - this will reset for real!)
        #   SupportEngine::Git::Gc.reset('./') #=> true
        # rubocop:disable Naming/PredicateMethod
        def reset(path)
          # rubocop:enable Naming/PredicateMethod
          Shell::Git.call_in_path(path, :reset, '--hard HEAD')
          Shell::Git.call_in_path(path, :clean, '-f -d')
          true
        end
      end
    end
  end
end
