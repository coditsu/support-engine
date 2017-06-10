# frozen_string_literal: true

module SupportEngine
  module Shell
    # Wrapper for executing git commands
    module Git
      class << self
        # Executes a given git command in path location
        # @param path [String] path of a current repository build
        # @param command [Symbol] name of a git command that we want to execute
        # @param arguments [String] all arguments accepted by this git command
        # @raise [SupportEngine::Errors::FailedShellCommand] raised when git command didn't
        #   run with success
        # @example
        #   shell('/home/builds/91', :log, "-n 1 --word-diff=porcelain --date=raw #{location}")
        def call_in_path(path, command, options)
          result = SupportEngine::Shell::Utf8.call("git -C #{path} #{command} #{options}")

          result[:stdout].split("\n")
        end
      end
    end
  end
end
