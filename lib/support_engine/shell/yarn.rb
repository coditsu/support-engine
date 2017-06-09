# frozen_string_literal: true

module SupportEngine
  module Shell
    # Wrapper for executing yarn commands
    module Yarn
      class << self
        # Executes a given yarn command
        # @param command [String] shell command that we want to execute
        # @param options [String] options for command
        # @return [Hash] Shell.call execution hash
        def call(command, options)
          Shell.call("yarn run --silent #{command} -- #{options}")
        end

        # @param path [String, Pathname] path to a place where git repo is
        # @param command [String] command that we want to execute in path context
        # @return [Hash] Shell.call execution hash
        def call_in_path(path, command, options)
          Shell.call("cd #{path.to_s.shellescape} && yarn run --silent #{command} -- #{options}")
        end
      end
    end
  end
end
