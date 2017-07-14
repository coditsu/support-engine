# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling commits
    # @note We use a trick here to group single commit data (that due to branches is multiline)
    #   we use '~' as a separator to distinguish between separate commits data (\n is not enough)
    #   Branches cannot have '~' in their names so we can use it without any risk
    module Commits
      class << self
        # Fetches all commits with additional details like date and branch
        # @param path [String, Pathname] path to a place where git repo is
        # @param since [Date] the earliest day for which we return data
        # @param limit [Integer] for how many commits  do we want log (1 for current)
        # @return [Array<Hash>] array with all commits hashes from repo from path
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        #
        # @example Run for current repo
        #   SupportEngine::Git::Commits.all('./') #=> [{:commit_hash=>"421cd..."]
        def all(path, since: 20.years.ago, limit: nil)
          cmd = [
            'git log --all --format="~%cD|%H"',
            "--since=\"#{since.to_s(:db)}\"",
            limit ? "-n#{limit}" : '',
            '| awk -F \'|\' \'{print $0; system("git branch -a --contains " $4)}\''
          ]

          result = SupportEngine::Shell.call_in_path(path, cmd.join(' '))
          fail_if_invalid(result)

          result[:stdout]
            .split('~')
            .delete_if(&:empty?)
            .map(&method(:build_commit))
        end

        # Fetches newest commit for each day with day details
        # @param path [String, Pathname] path to a place where git repo is
        # @param since [Date] the earliest day for which we return data
        # @return [Array<Hash>] array with the most recent commits per day in desc order
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        #
        # @example Run for current repo
        #   SupportEngine::Git::Commits.latest_by_day('./') #=>
        #     [{:commit_hash=>"421cd..."]
        def latest_by_day(path, since: 20.years.ago)
          cmd = [
            'git log --all --format="~%ci|%H"',
            "--since=\"#{since.to_s(:db)}\"",
            '--date=local | sort -u -r -k1,1',
            '| awk -F \'|\' \'{print $0; system("git branch -a --contains " $4)}\''
          ].join(' ')

          result = SupportEngine::Shell.call_in_path(path, cmd)
          fail_if_invalid(result)

          result[:stdout]
            .split('~')
            .delete_if(&:empty?)
            .map(&method(:build_commit))
        end

        private

        # Raises an error if there was anything wrong with the git command result
        # @param result [Hash] hash with shell command execution results
        def fail_if_invalid(result)
          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            unless result[:exit_code].zero?
          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            if result[:stderr].include?('Not a git repository')
        end

        # Builds a commit hash with basic details about single commit
        # @param raw_commit_data [String] raw string that describes a single commit
        # @return [Hash] hash with commit details (commit hash, date and branch)
        def build_commit(raw_commit_data)
          data = raw_commit_data.split("\n")
          base = data.shift.split('|')

          {
            commit_hash: base[1],
            committed_at: Time.zone.parse(base[0]),
            branch: resolve_branch(data)
          }
        end

        # Figures out the commit branch based on the candidates (if multiple)
        # When we clone from remote bare repository, we get branches with the origin/ prefix
        # and head pointer. Based on that we resolve to the head branch or we pick first one
        # from the list
        # @param candidates [Array<String>] array with branch names
        # @return [String, nil] nil if no branch detected for a given commit or a branch name
        #   if found
        def resolve_branch(candidates)
          candidates.each do |candidate|
            # We ignore detach information
            next if candidate.start_with?('*')

            candidate.gsub!('  remotes/origin/', '')

            return candidate.split('HEAD -> ').last if candidate.start_with?('HEAD')
            return candidate
          end

          ''
        end
      end
    end
  end
end
