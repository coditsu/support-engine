# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates new mirror repository from master repository
      class MasterMirror < Base
        class << self
          # Steps we need to take in order to setup dummy repository with --mirror
          def bootstrap
            destroy
            Git.clone_mirror(Master.location, location)
          end
        end
      end
    end
  end
end
