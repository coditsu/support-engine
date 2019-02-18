# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates new mirror repository from no master branch with broken head ref
      class BrokenHeadRefMirror < Base
        class << self
          # Steps we need to take in order to setup dummy repository with --mirror
          def bootstrap
            destroy
            Git.clone_mirror(BrokenHeadRef.location, location)
          end
        end
      end
    end
  end
end
