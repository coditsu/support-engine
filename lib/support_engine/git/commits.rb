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

      # Output format for each ref fetching
      EACH_REF_FORMAT = '%(committerdate)^%(objectname)^:%(refname)'

      class << self
        # Fetches all commits with additional details like date
        # @param path [String, Pathname] path to a place where git repo is
        # @param branch [String] branch name. Defaults to --all so we get all the commits
        #   from all the branches
        # @param since [Date] the earliest day for which we return data
        # @return [Array<Hash>] array with all commits hashes from repo from path
        # @note Does not return commits from pull requests
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        #
        # @example Run for current repo
        #   SupportEngine::Git::Commits.all('./') #=> [{:commit_hash=>"421cd..."]
        def all(path, branch: '--all', since: 20.years.ago)
          cmd = [
            "git log #{branch}", '--pretty="%cD^%H"', '--no-merges',
            "--since=\"#{since.to_s(:db)}\""
          ].join(' ')

          base = call_in_path!(path, cmd)[:stdout].split("\n")
          base.map! do |details|
            data = details.split('^')
            time = Time.zone.parse(data[0])
            { commit_hash: data[1], committed_at: time, source: 'origin' }
          end
          base.uniq! { |h| h[:commit_hash] }
          base
        end

        # Fetches newest commit for each day with day details
        # @param path [String, Pathname] path to a place where git repo is
        # @param branch [String] branch name. Defaults to --all so we get all the commits
        #   from all the branches
        # @param since [Date] the earliest day for which we return data
        # @param limit [Integer, nil] limit of commits that we want
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

          base = call_in_path!(path, cmd)[:stdout].split("\n")
          base.map! do |details|
            data = details.split('|')
            time = Time.zone.parse(data[0])
            { commit_hash: data[1], committed_at: time, source: 'origin' }
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
            "git for-each-ref refs/ --format='#{EACH_REF_FORMAT}'",
            '| grep \'heads\|remotes\'',
            '| grep -v HEAD',
            '| grep -v \'refs/pull\'',
            '| awk -F \'^\' \'!x[$1]++\''
          ].join(' ')

          clean_for_each_ref_results(
            call_in_path!(path, cmd)[:stdout].split("\n"),
            'origin'
          )
        end

        # Fetches newest pull request commits for a given repo
        # @note It does not distinguish between merged and unmerged pull request commits
        # @note It will work only when we fetch all the refs including refs/pull
        # @param path [String, Pathname] path to a place where git repo is
        # @param limit [Integer] limits of commits that we want
        # @example Run for current repo
        #   SupportEngine::Git::Commits.pull_requests('./') #=> []
        def pull_requests(path, limit: 50)
          cmd = [
            "git for-each-ref 'refs/pull/*/head' --format='#{EACH_REF_FORMAT}' --count #{limit}",
            '| awk -F \'^\' \'!x[$1]++\''
          ].join(' ')

          clean_for_each_ref_results(
            call_in_path!(path, cmd)[:stdout].split("\n"),
            'pull'
          )
        end

        private

        # Cleans data generated by latest_by_branch method
        # @note It does not resolve the branch name!
        # @param data [Array] output from latest_by_branch method
        # @param source [String] info whether this commits details come from origin or
        #   are from pull requests
        # @return [Array<Hash>] cleaned array
        # @example Run for current repo
        #   SupportEngine::Git::Commits.clean_for_each_ref_results(
        #     "
        #      Fri Aug 25 09:58:55 2017 +0200^38bd38^:refs/heads/different-branch\n
        #      Wed Aug 23 09:58:55 2017 +0200^e9a6bb^:refs/heads/master\n
        #     ",
        #     'origin'
        #   ) #=> [
        #   {
        #     :commit_hash=>"38bd382059e775e762c0c2b59601349a96585b28",
        #     :committed_at=>Fri, 25 Aug 2017 09:58:55 UTC +00:00,
        #     :source=>'origin'
        #   },
        #   {
        #     :commit_hash=>"e9a6bbfe15d89d2c089f1b86f404abe8ecf77e9c",
        #     :committed_at=>Wed, 23 Aug 2017 09:58:55 UTC +00:00,
        #     :source=>'origin'
        #   }
        #   ]
        def clean_for_each_ref_results(data, source)
          data.delete_if(&:empty?)
          data.map! { |commit| commit.split('^:').join("\n") }
          data.map! do |details|
            part1 = details.split('^')
            part2 = part1[1].split("\n")

            {
              commit_hash: part2[0],
              committed_at: Time.zone.parse(part1[0]),
              source: source
            }
          end
          data.uniq! { |h| h[:commit_hash] }
          data
        end
      end
    end
  end
end
