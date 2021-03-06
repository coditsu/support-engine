# frozen_string_literal: true

module SupportEngine
  module Git
    # Helper class that is used to create a dummy repository with some comits
    # on different branches that we can use to check if cloning, etc works as expected
    module RepoBuilder
      class << self
        # Creates a dummy repository in LOCATION with some commits and branches
        def bootstrap
          versions.each(&:bootstrap)
        end

        # Destroys dummy repository directory
        def destroy
          versions.each(&:destroy)
        end

        # Checks if repository is bare
        # @param path [String] local path to repository
        # @return [Boolean] true if repository is bare
        # @example Check if current repo is bare
        #   SupportEngine::Git::RepoBuilder.bare?(::Rails.root) #=> false
        def bare?(path)
          result = SupportEngine::Shell.call("cd #{path} && git rev-parse --is-bare-repository")
          result[:exit_code].zero? && result[:stdout].strip == 'true'
        end

        private

        # Repository can be in different states and versions (bare, mirror, etc)
        # This is a list off all the builders for all the versions, so we can
        # bootstrap that before we run test suite
        # @return [Array<Class>] Builders for all the version of repositories
        # @note We need to have them in a particular order (that's why we can't use #descendants)
        #   because some of them depend on others
        def versions
          ObjectSpace
            .each_object(Class)
            .select { |klass| klass < Base }
            .select { |klass| klass.to_s.include?('SupportEngine') }
            .sort_by(&:to_s)
        end
      end
    end
  end
end
