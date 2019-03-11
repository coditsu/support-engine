# frozen_string_literal: true

module SupportEngine
  module Git
    # Commands related to current git repository code state
    class Status < Base
      class << self
        # Returns list of introduced files that are not yet committed
        # @param path [String] path of a current repository build
        # @return [Array<String>] all new introduced not yet committed files
        # @example
        #   `touch test`
        #   SupportEngine::Git::Status.introduced('./') => ['test']
        def introduced(path)
          Shell::Git.call_in_path(
            path,
            'ls-files',
            '-o --exclude-standard'
          )
        end
      end
    end
  end
end
