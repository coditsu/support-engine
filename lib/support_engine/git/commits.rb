# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling commits
    module Commits
      class << self
        # Fetches all commits with
        # @param path [String, Pathname] path to a place where git repo is
        # @return [Array<String>] array with all commits hashes from repo from path
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        #
        # @example Run for current repo
        #   SupportEngine::Git::Commits.all('./') #=>  ["54222...", "fb62c..."]
        def all(path, since = 20.years.ago)
          cmd = [
            'git log', '--all', '--pretty="%H|%cD"', "--since=\"#{since.to_s(:db)}\""
          ].join(' ')

          result = SupportEngine::Shell.call_in_path(path, cmd)

          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            unless result[:exit_code].zero?
          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            if result[:stderr].include?('Not a git repository')

          result[:stdout].split("\n").map do |details|
            data = details.split('|')
            { commit_hash: data[0], committed_at: Time.zone.parse(data[1]) }
          end
        end

        # Fetches newest commit for each day with day details
        # @param path [String, Pathname] path to a place where git repo is
        # @return [Hash] hash where key is the day and value is a git commit hash
        # @raise [Errors::FailedShellCommand] raised when anything went wrong
        #
        # @example Run for current repo
        #   SupportEngine::Git::Commits.latest_by_day('./') #=>
        #     { 2016-11-03"=>"7a4...", "2016-11-04"=>"a614..." }
        def latest_by_day(path)
          command = 'git log --all --format="%ci|%H" --date=local | sort -u -k1,1'
          result = SupportEngine::Shell.call_in_path(path, command)

          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            unless result[:exit_code].zero?
          raise SupportEngine::Errors::FailedShellCommand, result[:stderr] \
            if result[:stderr].include?('Not a git repository')

          result_array = result[:stdout].split("\n")
          result_array.map! { |x| x.split('|') }
          result_array.map! { |z| [z[0].split(' ')[0], z[1]] }

          Hash[result_array]
        end
      end
    end
  end
end
