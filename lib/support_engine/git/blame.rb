# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling blame command
    module Blame
      class << self
        # Returns blame details about a given file
        # @param path [String] path of a current repository build
        # @param location [String] location of a file without sources_path
        # @return [Array<String>] Lines returned by the git blame command
        # @note It returns blame details about all the file contents not about a given line
        # @example
        #   SupportEngine::Git::Blame.all('./', 'Gemfile') #=>
        #     ["68c066bdc... 2 2 1", "author Maciej"]
        def all(path, location)
          Shell::Git.call_in_path(
            path,
            :blame,
            "#{Shell.escape(location)} -t --porcelain"
          )
        end

        # Returns blame details about a given line
        # @param path [String] path of a current repository build
        # @param location [String] location of a file without build_path
        # @param line [Integer] line that we want to blame against
        # @return [Array<String>] Lines returned by the git blame command
        # @example
        #   SupportEngine::Git::Blame.line('./', 'Gemfile', 2) #=>
        #     ["68c066bb5e0dc... 2 2 1", "author Maciej"]
        def line(path, location, line)
          options = "-t -L #{line},#{line} " \
            '--incremental --porcelain'

          Shell::Git.call_in_path(path, :blame, "'#{Shell.escape(location)}' #{options}")
        end
      end
    end
  end
end
