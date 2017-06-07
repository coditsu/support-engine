# frozen_string_literal: true

module SupportEngine
  module Git
    # Helper class that is used to create a dummy repository with some comits
    # on different branches that we can use to check if cloning, etc works as expected
    module RepoBuilder
      # Base class for all repository dummies. It provides an API for building
      # a test repository that will contain commits, etc and will be in a particular
      # state (mirror, bare, etc).
      class Base
        class << self
          # Where should we put our test dummy repo
          def location
            name = to_s.split('::').last.underscore
            File.join(SupportEngine.gem_root, 'tmp', "test_repo_#{name}")
          end

          # Creates a dummy repository in LOCATION with some commits and branches
          def bootstrap
            destroy
            SupportEngine::Shell.call(const_get(:BOOTSTRAP_CMD))
          end

          # Destroys dummy repository directory
          def destroy
            FileUtils.rm_r(location, secure: true) if Dir.exist?(location)
          end
        end
      end
    end
  end
end
