# frozen_string_literal: true

# Helper class that is used to create a dummy repository with some comits
# on different branches that we can use to check if cloning, etc works as expected
module GitRepoBuilder
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
    #   GitRepoBuilder.bare?(::Rails.root) #=> false
    def bare?(path)
      result = SupportEngine::Shell.call("cd #{path} && git rev-parse --is-bare-repository")
      result[:exit_code].zero? && result[:stdout].strip == 'true'
    end

    # Checkouts to a branch in a repository and tells us if it was successfull
    # @param path [String] local path to repository
    # @param branch [String] branch that we want to checkout to
    # @return [Boolean] true if we checkouted to a given branch
    # @example Checkout to a non existing branch of current repo
    #   GitRepoBuilder.checkout(::Rails.root, rand.to_s) #=> false
    def checkout?(path, branch)
      result = SupportEngine::Shell.call("cd #{path} && git checkout #{branch}", raise_on_invalid_exit: false)
      result[:exit_code].zero? && result[:stderr].strip == "Switched to branch '#{branch}'"
    end

    private

    # Repository can be in different states and versions (bare, mirror, etc) - this is a list
    # off all the builders for all the versions, so we can bootstrap that before we run test suit
    # @return [Array<Class>] Builders for all the version of repositories
    # @note We need to have them in a particular order (that's why we can't use #descendants)
    #   because some of them depend on others
    def versions
      [
        Repositories::Master,
        Repositories::MasterMirror,
        Repositories::NoMaster,
        Repositories::NoMasterMirror,
        Repositories::BrokenHeadRef,
        Repositories::BrokenHeadRefMirror
      ]
    end
  end
end
