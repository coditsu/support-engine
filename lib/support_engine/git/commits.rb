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

          clean_latest_by_branch(result[:stdout].split("\n"))
        end

        # Figures out the commit that branch originated from
        # @param path [String, Pathname] path to a place where git repo is
        # @param branch [String] branch on which we are on
        # @param commit_hash [String] git commit hash for which we want to get branch
        # @return [String] commit that branch originated from
        def originated_from(path, branch, commit_hash)
          result = nil

          Git.within_checkout(path, commit_hash, branch) do
            cmd = [
              'git merge-base',
              commit_hash,
              '$(git show-branch', '| sed "s/].*//"', '| grep "++"', '| grep -v',
              '"$(git rev-parse --abbrev-ref HEAD)"', '| head -n1', '| sed "s/^.*\[//")'
            ]
            result = SupportEngine::Shell.call_in_path(path, cmd)
            fail_if_invalid(result)
          end

          result[:stdout].strip
        end

        private

        # Cleans data generated by latest_by_branch method
        # @note It does not resolve the branch name!
        # @param data [Array] output from latest_by_branch method
        # @return [Array<Hash>] cleaned array
        # @example Run for current repo
        #   SupportEngine::Git::Commits.clean_latest_by_branch(
        #     "
        #      Fri Aug 25 09:58:55 2017 +0200^38bd38^:refs/heads/different-branch\n
        #      Wed Aug 23 09:58:55 2017 +0200^e9a6bb^:refs/heads/master\n
        #     "
        #   ) #=> [
        #   {
        #     :commit_hash=>"38bd382059e775e762c0c2b59601349a96585b28",
        #     :committed_at=>Fri, 25 Aug 2017 09:58:55 UTC +00:00
        #   },
        #   {
        #     :commit_hash=>"e9a6bbfe15d89d2c089f1b86f404abe8ecf77e9c",
        #     :committed_at=>Wed, 23 Aug 2017 09:58:55 UTC +00:00
        #   }
        #   ]
        def clean_latest_by_branch(data)
          data.delete_if(&:empty?)
          data.map! { |commit| commit.split('^:').join("\n") }
          data.map! do |details|
            v = details.split('^')
            { commit_hash: v[1].split("\n")[0], committed_at: Time.zone.parse(v[0]) }
          end
          data.uniq! { |h| h[:commit_hash] }
          data
        end
      end
    end
  end
end
