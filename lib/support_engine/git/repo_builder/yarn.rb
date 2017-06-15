# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with yarn and cloc installed, so we can test yarn run command
      class Yarn < Base
        # Steps we need to take in order to setup dummy repository
        BOOTSTRAP_CMD = [
          "git init #{location}",
          "cd #{location}",
          'yarn init -y',
          'yarn add cloc',
          'git add --all ./',
          commit('master commit'),
          'git branch different-branch',
          'git checkout different-branch',
          'touch different-branch.txt',
          'git add --all ./',
          commit('different-branch commit'),
          'git checkout master',
          "git remote add origin #{origin}"
        ].join(' && ').freeze
      end
    end
  end
end
