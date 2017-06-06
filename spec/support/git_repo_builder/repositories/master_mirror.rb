# frozen_string_literal: true

module GitRepoBuilder
  module Repositories
    # Creates new mirror repository from master repository
    class MasterMirror < Base
      # Steps we need to take in order to setup dummy repository with --mirror
      BOOTSTRAP_CMD = "git clone --mirror #{Master.location} #{location}/.git/"
    end
  end
end
