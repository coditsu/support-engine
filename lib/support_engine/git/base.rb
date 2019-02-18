# frozen_string_literal: true

module SupportEngine
  module Git
    # Base class for all the git wrappers
    class Base
      class << self
        private

        # @param path [String, Pathname] path to a place where git repo is
        # @param cmd [String] command we want to execute
        # @return [Hash] hash with 3 keys describing output (stdout, stderr, exit_code)
        # @raise [SupportEngine::Errors::FailedShellCommand] raised when we try to do
        #   something weird or in a non git repo
        def call_in_path!(path, cmd)
          fail_if_invalid SupportEngine::Shell.call_in_path(path, cmd)
        end

        # Raises an error if there was anything wrong with the git command result
        # @param result [Hash] hash with shell command execution results
        def fail_if_invalid(result)
          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            unless result[:exit_code].zero?
          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            if result[:stderr].downcase.include?('not a git repository')

          result
        end
      end
    end
  end
end
