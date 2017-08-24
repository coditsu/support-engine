# frozen_string_literal: true

module SupportEngine
  # Module for executing git commands that we use in this app
  module Git
    class << self
      # Clones a mirror of the source repository to a local copy
      # @param remote_path [String] url to a remote copy
      # @param local_path [String] local path to which we clone
      # @return [Boolean] true if repository got cloned
      # @raise [Errors::FailedShellCommand] raised when anything went wrong
      def clone_mirror(remote_path, local_path)
        Shell.call("git clone --mirror #{remote_path} #{local_path}/.git/")
        Shell.call_in_path(local_path, 'git remote update --prune')
        Shell.call_in_path(local_path, 'git config --bool core.bare false')
        Shell.call_in_path(local_path, "git checkout #{Git::Ref.head!(local_path)}")

        true
      end

      # Get file count tracked by git
      # @param path [String] path of a current repository build
      # @return [Integer] number of files tracked by git
      def tracked_files_count(path)
        Shell::Git.call_in_path(path, 'ls-files', '| wc -l').first.to_i
      end

      # Switch to a branch or commit
      # @param path [String] path of a current repository build
      # @param ref [String] branch or commit that we want to checkout to
      # @return [Boolean] true if we were able to checkout
      def checkout(path, ref)
        result = SupportEngine::Shell.call_in_path(
          path,
          "git checkout #{ref}",
          raise_on_invalid_exit: false
        )
        result[:exit_code].zero? && checkout_success?(result[:stderr], ref)
      end

      # Run commands within a checkout ref, we have commands that need to be run within
      # a specific ref, Git::Commits.originated_from for example
      # @param path [String] path of a current repository build
      # @param ref [String] branch or commit that we want to checkout to
      # @return [Boolean] true if we were able to checkout
      def within_checkout(path, ref, original_ref)
        Git.checkout(path, ref)
        yield
        Git.checkout(path, original_ref)
      end

      private

      # Returns true if message is matched
      # @param message [String] response message from shell command
      # @param ref [String] branch or commit that we want to checkout to
      # @return [Boolean] true if message is matched
      def checkout_success?(message, ref)
        checkout_branch_success?(message, ref) || checkout_commit_success?(message, ref)
      end

      # Returns true if message for branch checkout is matched
      # @param message [String] response message from shell command
      # @param branch [String] branch that we want to checkout to
      # @return [Boolean] true if message is matched
      # @example
      #   SupportEngine::Git.checkout_branch_success?("Already on 'master'", 'master')
      #     #=> true
      def checkout_branch_success?(message, branch)
        [
          "Switched to branch '#{branch}'",
          "Already on '#{branch}'"
        ].include?(message.strip)
      end

      # Returns true if message for commit checkout is matched
      # @param message [String] response message from shell command
      # @param commit [String] commit hash that we want to checkout to
      # @return [Boolean] true if message is matched
      # @example
      #   SupportEngine::Git.checkout_commit_success?(
      #     "HEAD is now at ff3221e... master commit",
      #     'ff3221e8be98f2da23b887e38028c4918e00915b'
      #   ) #=> true
      def checkout_commit_success?(message, commit)
        !message.strip.match(/HEAD is now at #{commit[0..6]}.../).nil?
      end
    end
  end
end
