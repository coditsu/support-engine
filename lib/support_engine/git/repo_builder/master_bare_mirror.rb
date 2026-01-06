# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates new mirror repository from master repository
      class MasterBareMirror < Base
        # Steps we need to take in order to setup dummy repository with --mirror
        def self.bootstrap_cmd
          "git clone --mirror #{Master.location} #{location}/.git/"
        end
      end
    end
  end
end
