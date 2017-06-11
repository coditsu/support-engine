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

      # Returns blame details about a given file
      # @param path [String] path of a current repository build
      # @param location [String] location of a file without sources_path
      # @return [Array<String>] Lines returned by the git blame command
      # @note It returns blame details about all the file contents not about a given line
      # @example
      #   SupportEngine::Git.blame('./', 'Gemfile') #=> ["68c066bdc... 2 2 1", "author Maciej"]
      def blame(path, location)
        Shell::Git.call_in_path(
          path,
          :blame,
          "#{Shell.escape(location)} -t --porcelain"
        )
      end

      # Returns blame details about a given line
      # @param path [String] path of a current repository build
      # @param location [String] location of a file without build_path
      # @param line [Integer] line that we want to blame against
      # @return [Array<String>] Lines returned by the git blame command
      # @example
      #   SupportEngine::Git.blame_line('./', 'Gemfile', 2) #=>
      #   ["68c066bb5e0dc... 2 2 1", "author Maciej"]
      def blame_line(path, location, line)
        options = "-t -L #{line},#{line} " \
          '--incremental --porcelain'

        Shell::Git.call_in_path(path, :blame, "'#{location}' #{options}")
      end
    end
  end
end
