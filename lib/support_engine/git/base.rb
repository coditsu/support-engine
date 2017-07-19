# frozen_string_literal: true

module SupportEngine
  module Git
    # Base class for all the git wrappers
    class Base
      class << self
        private

        # Raises an error if there was anything wrong with the git command result
        # @param result [Hash] hash with shell command execution results
        def fail_if_invalid(result)
          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            unless result[:exit_code].zero?
          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            if result[:stderr].include?('Not a git repository')
        end
      end
    end
  end
end
