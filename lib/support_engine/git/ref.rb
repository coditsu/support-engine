# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for executing git commands on references
    class Ref < Base
      class << self
        # Returns latest reference in a local repository
        # @param local_path [String] local path to which we clone
        # @return [String] latest reference
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        # @example
        #   Git::Ref.latest(<local_path>) #=> refs/heads/develop
        def latest(local_path)
          result = Shell.call_in_path(local_path, "git show-ref|head -1|awk -F' ' '{print $2}'")
          result[:stdout].strip
        end

        # Returns HEAD branch of a local repository
        # @param local_path [String] local path to which we clone
        # @param raise_on_invalid_exit [Boolean] if anything goes wrong, should we raise or ignore
        # @return [Hash] hash with 3 keys describing output
        #   (stdout, stderr, exit_code)
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        # @example
        #   Git::Ref.head(<local_path>) #=>
        #     {:stdout=>"develop\n", :stderr=>"", :exit_code=>0}
        def head(local_path, raise_on_invalid_exit = true)
          Shell.call_in_path(
            local_path,
            'git rev-parse --abbrev-ref HEAD',
            raise_on_invalid_exit: raise_on_invalid_exit
          )
        end

        # Returns HEAD branch of a local repository
        # This methods sets HEAD if it is not set
        # @param local_path [String] local path to which we clone
        # @return [String] branch name
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        # @example
        #   Git::Ref.head!(<local_path>) #=> develop
        def head!(local_path)
          result = head(local_path, false)
          return result[:stdout].strip if head?(result)

          Shell.call_in_path(local_path, "git symbolic-ref HEAD #{latest(local_path)}")
          head(local_path)[:stdout].strip
        end

        # Returns true if HEAD is set on local repository
        # @param result [Hash] hash with 3 keys describing output
        #   (stdout, stderr, exit_code)
        # @return [Boolean]
        def head?(result)
          result[:stderr].empty? || \
            !result[:stderr].include?(
              "fatal: ambiguous argument 'HEAD': " \
              'unknown revision or path not in the working tree'
            )
        end
      end
    end
  end
end
