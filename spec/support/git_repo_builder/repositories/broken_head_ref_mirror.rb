# frozen_string_literal: true

module GitRepoBuilder
  module Repositories
    # Creates new mirrorrepository from no master branch with broken head ref
    class BrokenHeadRefMirror < Base
      # Steps we need to take in order to setup dummy repository with --mirror
      BOOTSTRAP_CMD = "git clone --mirror #{BrokenHeadRef.location} #{location}/.git/"
    end
  end
end
