# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling log
    class Log < Base
      class << self
        # Returns a shortlog describing all the commiters for project that is
        #   under path
        # @param path [String] path of a current repository build
        # @return [Array<String>] Lines returned by the git shortlog command
        # @example
        #   SupportEngine::Git::Log.shortlog('./') #=>
        #   ["    13\tMaciej Mensfeld <maciej@mensfeld.pl>"]
        def shortlog(path)
          Shell::Git.call_in_path(path, :shortlog, '-sn -e --all')
        end

        # Returns an information about last commiter that changed/created this
        #   file. We use it to blame users for file related errors, assuming that
        #   the fault goes always to a person that changed the file last and
        #   didn't correct or created a particular error
        # @param path [String] path of a current repository build
        # @param location [String] location of a file (without build_path)
        # @return [Array<String>] Lines returned by the git log command
        # @example
        #   SupportEngine::Git::Log.file_last_committer('./', 'Gemfile') #=>
        #   ["commit 68c066bb5e0dc3ef5", "Author: M..."]
        def file_last_committer(path, location)
          location = Shell.escape(location) if location
          # We had to add "--" before the location because:
          #   https://stackoverflow.com/questions/26349191
          Shell::Git.call_in_path(
            path,
            :log,
            "-n 1 --word-diff=porcelain --date=raw -- '#{location}'"
          )
        end

        # Runs a git log with --shortstats option
        # @param path [String] path of a current repository build
        # @param limit [Integer, nil] number of lines that we want
        # @param since [Date] since when we want to get the shortstat
        # @return [Array<String>] Lines returned by the git log --shortstat command
        # @example
        #   SupportEngine::Git::Log.shortstat('./', 2) #=>
        #   [
        #     '4 files changed, 13 insertions(+), 36 deletions(-)',
        #     'ab7928cc003e2306c9d7ec729fb1d87e808337c0 ninshiki'
        #   ]
        def shortstat(path, limit: nil, since: 20.years.ago)
          options = []
          options << '--shortstat'
          options << "--since=\"#{since.to_formatted_s(:db)}\""
          options << '--format="oneline"'
          options << "-n#{limit}" if limit

          Shell::Git.call_in_path(path, :log, options.join(' '))
        end

        # @param path [String] path of a current repository build
        # @return [DateTime] datetime of a head commit
        def head_committed_at(path)
          Time.zone.parse(Shell::Git.call_in_path(path, :log, '-1 --format=%cd').first)
        end
      end
    end
  end
end
