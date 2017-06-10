# frozen_string_literal: true

module SupportEngine
  module Shell
    # Wrapper for executing yarn commands
    module Yarn
      class << self
        # Executes a given yarn command
        # @param command [String] shell command that we want to execute
        # @param command_options [String] options that we want to pass to command
        # @param options [String] options that we want to pass to Shell.call
        # @return [Hash] Shell.call execution hash
        def call(command, command_options, options = { raise_on_invalid_exit: true })
          Shell.call("yarn run --silent #{command} -- #{command_options}", options)
        end

        # @param path [String, Pathname] path to a place where git repo is
        # @param command [String] command that we want to execute in path context
        # @param command_options [String] options that we want to pass to command
        # @param options [String] options that we want to pass to Shell.call
        # @return [Hash] Shell.call execution hash
        def call_in_path(path, command, command_options, options = { raise_on_invalid_exit: true })
          Shell.call(
            "cd #{path.to_s.shellescape} && yarn run --silent #{command} -- #{command_options}",
            options
          )
        end
      end
    end
  end
end
