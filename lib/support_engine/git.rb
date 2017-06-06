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

      # Fetches newest commit for each day with day details
      # @param [String, Pathname] path to a place where git repo is
      # @return [Hash] hash where key is the day and value is a git commit hash
      # @raise [Errors::FailedShellCommand] raised when anything went wrong
      #
      # @example Run for current repo
      #   SupportEngine::Git.commits('./') #=> { 2016-11-03"=>"7a4...", "2016-11-04"=>"a614..." }
      def commits(path)
        command = 'git log --all --format="%ci|%H" --date=local | sort -u -k1,1'
        result = Shell.call_in_path(path, command)

        raise Errors::FailedShellCommand, result[:stderr] \
          unless result[:exit_code].zero?
        raise Errors::FailedShellCommand, result[:stderr] \
          if result[:stderr].include?('Not a git repository')

        result_array = result[:stdout].split("\n")
        result_array.map! { |x| x.split('|') }
        result_array.map! { |z| [z[0].split(' ')[0], z[1]] }

        Hash[result_array]
      end
    end
  end
end
