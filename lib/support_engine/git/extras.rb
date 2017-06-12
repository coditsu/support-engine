# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling git-extras commands
    # @see https://github.com/tj/git-extras
    module Extras
      class << self
        # Runs git effort
        # @note We remove all the colors and sort before returning results
        # @param path [String] path of a current repository build
        # @param since [String] since when we want to check offerts
        # @param above [Integer] above what effort level we expect results
        #   It is useless to get all of them as it takes a lot of time and most of the time,
        #   the most interesting once are those with higher rank
        # @return [Array<String>] array with blame results
        # @example SupportEngine::Git::Extras.effort('./', '2017-02-01', 5) #=>
        # [
        #   "  Gemfile.lock................................. 8           7",
        #   "  path      ..."
        # ]
        def effort(path, since, above = 10)
          options = []
          options << "--above #{above}"
          options << '--'
          options << "--since=\"#{since}\""

          # Remove all the colors from the output
          options << '| sed "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
          options << '| sort -rn -k 2'
          options << '| uniq'

          Shell::Git.call_in_path(path, :effort, options.join(' '))
        end
      end
    end
  end
end
