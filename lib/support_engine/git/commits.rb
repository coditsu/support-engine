# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling commits
    module Commits
      class << self
        # When we want to resolve branches, we do that based on refs. Refs containt
        # name prefixes that we don't need so this is a map of prefixes that we have to remove
        # in order to get proper branch names
        UNWANTED_PREFIXES = %w[
          refs/remotes/origin/
          refs/remotes/
          refs/heads/
          refs/
        ].freeze

        # When commit is present in multiple branches, those branches have priority in terms of being
        # returned as the main branch of the commit
        PRIORITIZED_BRANCHES = %w[
          master
          develop
          release
        ]

        # Fetches all commits with additional details like date
        # @param path [String, Pathname] path to a place where git repo is
        # @param since [Date] the earliest day for which we return data
        # @param limit [Integer] for how many commits  do we want log (1 for current)
        # @return [Array<Hash>] array with all commits hashes from repo from path
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        #
        # @example Run for current repo
        #   SupportEngine::Git::Commits.all('./') #=> [{:commit_hash=>"421cd..."]
        def all(path, since: 20.years.ago)
          cmd = [
            'git log',
            '--all',
            '--pretty="%cD|%H"',
            '--no-merges',
            "--since=\"#{since.to_s(:db)}\""
          ].join(' ')

          result = SupportEngine::Shell.call_in_path(path, cmd)
          fail_if_invalid(result)

          base = result[:stdout].split("\n")
          base.map! do |details|
            data = details.split('|')
            { commit_hash: data[1], committed_at: Time.zone.parse(data[0]) }
          end
          base.uniq! { |h| h[:commit_hash] }
          base
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
            'git log',
            '--all',
            '--format="%ci|%H"',
            '--date=local',
            "--since=\"#{since.to_s(:db)}\"",
            '| sort -u -r -k1,1'
          ].join(' ')

          result = SupportEngine::Shell.call_in_path(path, cmd)
          fail_if_invalid(result)

          base = result[:stdout].split("\n")
          base.map! do |details|
            data = details.split('|')
            { commit_hash: data[1], committed_at: Time.zone.parse(data[0]) }
          end
          base.uniq! { |h| h[:commit_hash] }
          base
        end

        # Fetches newest commit for each branch that is in the repository (for its current state)
        # @note It does not resolve the branch name!
        # @param path [String, Pathname] path to a place where git repo is
        # @return [Array<Hash>] array with the latest commit per each branch
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        def latest_by_branch(path)
          cmd = [
            'git for-each-ref refs/ --format=\'%(committerdate)^%(objectname)^:%(refname)\'',
            '| grep \'heads\|remotes\'',
            '| grep -v HEAD',
            '| grep -v \'refs/pull\'',
            '| awk -F \'^\' \'!x[$1]++\''
          ].join(' ')

          result = SupportEngine::Shell.call_in_path(path, cmd)
          fail_if_invalid(result)

          base = result[:stdout].split("\n")
          base.delete_if(&:empty?)
          base.map! { |commit| commit.split('^:').join("\n") }
          base.map! do |details|
            data = details.split('^')
            { commit_hash: data[1].split("\n")[0], committed_at: Time.zone.parse(data[0]) }
          end
          base.uniq! { |h| h[:commit_hash] }
          base
        end

        # @param path [String, Pathname] path to a place where git repo is
        # @param commit_hash [String] git commit hash for which we want to get branch
        # @return [String] comit branch name
        def branch(path, commit_hash)
          cmd = [
            'git for-each-ref --contains',
            commit_hash,
            '| grep -v \'refs/pull/\' | cat'
          ]

          result = SupportEngine::Shell.call_in_path(path, cmd)
          fail_if_invalid(result)

          # We need to know the main head of the repo, for branch picking
          # In case there are multiple branches containing same commit, we prioritize
          # head as the owner of a commit
          head = Ref.head(path)[:stdout].delete("\n")

          # If the head points to HEAD it means that the repo is in the detach state
          # and we need to pick the latest ref to get a head branch
          head = head == 'HEAD' ? sanitize_branch(Ref.latest(path)) : head

          resolve_branch result[:stdout].split("\n"), commit_hash, head
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

        # Figures out the commit branch based on the candidates (if multiple)
        # When we clone from remote bare repository, we get branches with the origin/ prefix
        # and head pointer. Based on that we resolve to the head branch or we pick first one
        # from the list
        # @param each_ref [Array<String>] array with for-each-ref results
        # @return [String, nil] nil if no branch detected for a given commit or a branch name
        #   if found
        def resolve_branch(each_ref, commit_hash, head)
          # We prioritize head branches as main branches of a commit if they are in the head
          return head if each_ref.any? do |candidate|
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

          branch = candidates.find do |candidate|
            PRIORITIZED_BRANCHES.any? { |pb| candidate.include?(pb) }
          end

          branch ||= candidates.first.to_s

          # And we pick the first one with and sanitize it to get only the branch name
          branch.tap(&method(:sanitize_branch))
        end

        # Removes unwanted prefixes from branch name
        # @param branch [String] branch name
        # @return [String] sanitized same branch name
        def sanitize_branch(branch)
          UNWANTED_PREFIXES.each { |prefix| branch.gsub!(prefix, '') }
          branch
        end
      end
    end
  end
end
