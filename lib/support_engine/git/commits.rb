# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling commits
    class Commits < Base
      # When we want to resolve branches, we do that based on refs. Refs containt
      # name prefixes that we don't need so this is a map of prefixes that we have to remove
      # in order to get proper branch names
      UNWANTED_PREFIXES = %w[
        refs/remotes/origin/
        refs/remotes/
        refs/heads/
        refs/
      ].freeze

      # When commit is present in multiple branches, those branches have priority in terms
      # of being returned as the main branch of the commit
      PRIORITIZED_BRANCHES = %w[
        master
        develop
        release
      ].freeze

      # Limit originated from check to this limit, if we are not able to determine branch by this
      # limit then we fail
      ORIGINATED_FROM_LIMIT = 50

      class << self
        # Fetches all commits with additional details like date
        # @param path [String, Pathname] path to a place where git repo is
        # @param branch [String] branch name. Defaults to --all so we get all the commits
        #   from all the branches
        # @param since [Date] the earliest day for which we return data
        # @return [Array<Hash>] array with all commits hashes from repo from path
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        #
        # @example Run for current repo
        #   SupportEngine::Git::Commits.all('./') #=> [{:commit_hash=>"421cd..."]
        def all(path, branch: '--all', since: 20.years.ago)
          cmd = [
            "git log #{branch}", '--pretty="%cD|%H"', '--no-merges',
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
        # @param branch [String] branch name. Defaults to --all so we get all the commits
        #   from all the branches
        # @param since [Date] the earliest day for which we return data
        # @param limit [Integer, nil] limmit of commits that we want
        # @return [Array<Hash>] array with the most recent commits per day in desc order
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        #
        # @example Run for current repo
        #   SupportEngine::Git::Commits.latest_by_day('./') #=>
        #     [{:commit_hash=>"421cd..."]
        def latest_by_day(path, branch: '--all', since: 20.years.ago, limit: nil)
          cmd = [
            "git log #{branch} --date=local", '--format="%ci|%H"',
            "--since=\"#{since.to_s(:db)}\"", limit ? "-n#{limit}" : '', '| sort -u -r -k1,1'
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

        # Figures out the commit that branch originated from
        # @param path [String, Pathname] path to a place where git repo is
        # @param commit_hash [String] git commit hash for which we want to get branch
        # @return [String] commit that branch originated from
        def originated_from(path, commit_hash)
          cmd = ["git checkout #{commit_hash}"]

          SupportEngine::Shell.call_in_path(path, cmd.join(''))

          cmd = [
            'git show-branch',
            '| sed "s/].*//"',
            '| grep "++"',
            '| grep -v',
            '"$(git rev-parse --abbrev-ref HEAD)"',
            '| head -n1',
            '| sed "s/^.*\[//"'
          ]
          result = SupportEngine::Shell.call_in_path(path, cmd)

          result = SupportEngine::Shell.call_in_path(
            path,
            "git merge-base #{commit_hash} #{result[:stdout].strip}"
          )

          fail_if_invalid(result)

          SupportEngine::Shell.call_in_path(path, 'git checkout master')

          result[:stdout].strip
        end
      end
    end
  end
end
