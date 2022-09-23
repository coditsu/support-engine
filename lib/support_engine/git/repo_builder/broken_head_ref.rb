# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with no main branch and broken head ref
      class BrokenHeadRef < Base
        # Steps we need to take in order to setup dummy repository
        BOOTSTRAP_CMD = [
          "git init #{location}",
          "cd #{location}",
          'echo "hash = { \'test\' => 1 }" > main.rb',
          'git add --all ./',
          commit('main commit'),
          'git branch develop',
          'git checkout develop',
          'echo "hash = { \'test\' => 2 }" > develop.rb',
          'git add --all ./',
          commit('develop commit'),
          'git branch different-branch',
          'git checkout different-branch',
          'touch different-branch.txt',
          'git add --all ./',
          commit('different-branch commit'),
          'git checkout develop',
          "git remote add origin #{origin}",
          'git branch -D main',
          'echo "ref: refs/heads/main" > .git/HEAD'
        ].join(' && ').freeze
      end
    end
  end
end
