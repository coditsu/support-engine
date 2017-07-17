# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling commits
    # @note We use a trick here to group single commit data (that due to branches is multiline)
    #   we use '~' and '^' as a separators to distinguish between separate commits data because
    #   (\n is not enough). Branches cannot have '~' and '^' in their names so we can use it
    #   without any risk.
    module Commits
      # When we want to resolve branches, we do that based on refs. Refs containt
      # name prefixes that we don't need so this is a map of prefixes that we have to remove
      # in order to get proper branch names
      UNWANTED_PREFIXES = %w[
        refs/remotes/origin/
        refs/remotes/
        refs/heads/
        refs/
      ].freeze

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
            'git log --all --format="~%cD^%H"',
            "--since=\"#{since.to_s(:db)}\"",
            limit ? "-n#{limit}" : '',
            '| awk -F \'^\' \'{print $0; system("git for-each-ref --contains " $2)}\''
          ]

          result = SupportEngine::Shell.call_in_path(path, cmd.join(' '))
          fail_if_invalid(result)

          # We need to know the main head of the repo, for branch picking
          # In case there are multiple branches containing same commit, we prioritize
          # head as the owner of a commit
          head = Ref.head(path)[:stdout].delete("\n")

          # If the head points to HEAD it means that the repo is in the detach state
          # and we need to pick the latest ref to get a head branch
          head = head == 'HEAD' ? sanitize_branch(Ref.latest(path)) : head

          result[:stdout]
            .split('~')
            .delete_if(&:empty?)
            .map! { |commit| build_commit(commit, head) }
        end

        # Fetches newest commit for each day with day details
        # @param path [String, Pathname] path to a place where git repo is
        # @param since [Date] the earliest day for which we return data
        # @return [Array<Hash>] array with the most recent commits per day in desc order
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        # @note latest_by_day does not contain a branch name
        #
        # @example Run for current repo
        #   SupportEngine::Git::Commits.latest_by_day('./') #=>
        #     [{:commit_hash=>"421cd..."]
        def latest_by_day(path, since: 20.years.ago)
          cmd = [
            'git log --all --format="%ci^%H"',
            "--since=\"#{since.to_s(:db)}\"",
            '--date=local | sort -u -r -k1,1'
          ].join(' ')

          result = SupportEngine::Shell.call_in_path(path, cmd)
          fail_if_invalid(result)

          result[:stdout]
            .split("\n")
            .delete_if(&:empty?)
            .map! { |commit| build_commit(commit, nil) }
        end

        # Fetches newest commit for each branch that is in the repository (for its current state)
        # @param path [String, Pathname] path to a place where git repo is
        # @return [Array<Hash>] array with the latest commit per each branch
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        def latest_by_branch(path)
          cmd = [
            'git for-each-ref refs/ --format=\'%(committerdate)^%(objectname)^:%(refname)\'',
            ' | grep \'heads\|remotes\|pull\' | grep -v HEAD | awk -F \'^\' \'!x[$1]++\''
          ].join(' ')

          result = SupportEngine::Shell.call_in_path(path, cmd)
          fail_if_invalid(result)

          # We fake head here, because otherwise it would return nil as it would catch
          # into the head detection loop (this is a cornercase because latest by branch
          # has a different bash git command)
          result[:stdout]
            .split("\n")
            .delete_if(&:empty?)
            .map! { |commit| commit.split('^:').join("\n") }
            .map! { |commit| build_commit(commit, ':') }
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
        def build_commit(raw_commit_data, head)
          data = raw_commit_data.split("\n")
          base = data.shift.split('^')

          resolve_branch_and_pull_request(data, base[1], head).merge(
            commit_hash: base[1],
            committed_at: Time.zone.parse(base[0])
          )
        end

        # Figures out the commit branch based on the candidates (if multiple) and if this branch
        # is an external pull request branch from an external source (local pull request that
        # are committed in the same repo are not distinguishable from other normal branches)
        # When we clone from remote bare repository, we get branches with the origin/ prefix
        # and head pointer. Based on that we resolve to the head branch or we pick first one
        # from the list
        # @param each_ref [Array<String>] array with for-each-ref results
        # @return [String, nil] nil if no branch detected for a given commit or a branch name
        #   if found
        def resolve_branch_and_pull_request(each_ref, commit_hash, head)
          # We prioritize head branches as main branches of a commit if they are in the head
          return { branch: head, external_pull_request: false } if each_ref.any? do |candidate|
            candidate.include?('origin/HEAD') || candidate.include?("refs/heads/#{head}")
          end

          # First we select only those branches that not only contain but have our commit as
          # the last one (when we are checkout it will work like that as well). For the head
          # commits this is the most accurate
          candidates = each_ref.select { |ref| ref.start_with?(commit_hash) }
          # And if non like that, we just fallback to all branches and pick the first one
          candidates = each_ref if candidates.empty?

          # We pick only the branch name part as the bash command result contains some noise
          candidates.map! { |candidate| candidate.split("\t").last }

          # And we pick the first one with and sanitize it to get only the branch name
          branch = candidates
                   .first
                   .to_s
                   .tap(&method(:sanitize_branch))

          { branch: branch, external_pull_request: branch.include?('pull') }
        end

        def sanitize_branch(branch)
          UNWANTED_PREFIXES.each { |prefix| branch.gsub!(prefix, '') }
          branch
        end
      end
    end
  end
end
