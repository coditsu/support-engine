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
    end
  end
end
