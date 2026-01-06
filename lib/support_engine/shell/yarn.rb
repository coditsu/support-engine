# frozen_string_literal: true

module SupportEngine
  module Shell
    # Wrapper for executing yarn commands
    module Yarn
      class << self
        # Executes a given yarn command
        # @param command [String] shell command that we want to execute
        # @param options [String] options that we want to pass to command
        # @param raise_on_invalid_exit [Boolean] raise exception when exit code is not 0
        # @return [Hash] Shell.call execution hash
        def call(command, options, raise_on_invalid_exit: true)
          Shell::Utf8.call(
            "yarn run --silent #{command} #{options}",
            raise_on_invalid_exit:
          )
        end

        # @param path [String, Pathname] path to a place where git repo is
        # @param command [String] command that we want to execute in path context
        # @param options [String] options that we want to pass to command
        # @param raise_on_invalid_exit [Boolean] raise exception when exit code is not 0
        # @return [Hash] Shell.call execution hash
        def call_in_path(path, command, options, raise_on_invalid_exit: true)
          Shell::Utf8.call_in_path(
            path,
            "yarn run --silent #{command} #{options}",
            raise_on_invalid_exit:
          )
        end
      end
    end
  end
end
