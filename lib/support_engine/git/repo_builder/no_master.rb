# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with no master branch
      class NoMaster < Base
        # Steps we need to take in order to setup dummy repository
        def self.bootstrap_cmd
          [
            "git init #{location}",
            "cd #{location}",
            'echo "hash = { \'test\' => 1 }" > master.rb',
            'git add --all ./',
            commit('master commit'),
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
            'git branch -D master'
          ].join(' && ')
        end
      end
    end
  end
end
