# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling commits
    module Gc
      class << self
        # Performs a cleaning of useless git data
        # @param path [String, Pathname] path to a place where git repo is
        # @return [Boolean] true if everything went fine
        # @raise [SupportEngine::Errors::FailedShellCommand] raised when anything went wrong
        # @example Cleanup current repo
        #   SupportEngine::Git::Gc.prune(Rails.root) #=> true
        def prune(path)
          result = SupportEngine::Shell.call_in_path(path, 'git gc --prune -q')

          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            unless result[:exit_code].zero?
          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            if result[:stderr].include?('Not a git repository')

          true
        end
      end
    end
  end
end
