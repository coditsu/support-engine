# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with master branch
      class Master < Base
        # Steps we need to take in order to setup dummy repository
        def self.bootstrap_cmd
          [
            "git init #{location}",
            "cd #{location}",
            'echo "hash = { \'test\' => 1 }" > master.rb',
            'git add --all ./',
            commit('master commit', committed_at: 2.days.ago),
            'git branch different-branch',
            'git checkout different-branch',
            'touch different-branch.txt',
            'git add --all ./',
            commit('different-branch commit'),
            'git checkout master',
            "git remote add origin #{origin}"
          ].join(' && ')
        end
      end
    end
  end
end
