# frozen_string_literal: true

module SupportEngine
  module Shell
    # Wrapper for executing git commands
    module Git
      class << self
        # Executes a given git command in path location
        # @param path [String] path of a current repository build
        # @param command [Symbol] name of a git command that we want to execute
        # @param options [String] options that we want to pass to command
        # @param raise_on_invalid_exit [Boolean] raise exception when exit code is not 0
        # @raise [SupportEngine::Errors::FailedShellCommand] raised when git command didn't
        #   run with success
        # @example
        #   call_in_path('/home/91', :log, "-n 1 --word-diff=porcelain --date=raw #{location}")
        def call_in_path(path, command, options, raise_on_invalid_exit: true)
          result = SupportEngine::Shell::Utf8.call(
            "git -C #{path} #{command} #{options}",
            raise_on_invalid_exit:
          )

          result[:stdout].split("\n")
        end
      end
    end
  end
end
