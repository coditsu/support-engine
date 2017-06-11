# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling log
    module Log
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
        #   SupportEngine::Git::Log.log('./', 'Gemfile') #=>
        #   ["commit 68c066bb5e0dc3ef5", "Author: M..."]
        def file_last_committer(path, location)
          location = Shell.escape(location) if location
          Shell::Git.call_in_path(
            path,
            :log,
            "-n 1 --word-diff=porcelain --date=raw '#{location}'"
          )
        end
      end
    end
  end
end
