# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates new mirror repository from big branch repository
      class MasterWithBigBranchMirror < Base
        class << self
          # Steps we need to take in order to setup dummy repository with --mirror
          def bootstrap
            destroy
            Git.clone_mirror(MasterWithBigBranch.location, location)
          end
        end
      end
    end
  end
end
