# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with big branch with more than 50 commits on a branch
      class MasterWithBigBranch60 < Base
        # Create changes in a branch
        def self.create_commits
          60.downto(0).flat_map do |number|
            [
              "touch different-branch-#{number}.txt",
              'git add --all ./',
              commit("different-branch commit #{number}", committed_at: number.days.ago)
            ]
          end
        end

        # Steps we need to take in order to setup dummy repository
        def self.bootstrap_cmd
          [
            "git init #{location}",
            "cd #{location}",
            'echo "hash = { \'test\' => 1 }" > master.rb',
            'git add --all ./',
            commit('master commit', committed_at: 90.days.ago),
            'git branch different-branch',
            'git checkout different-branch',
            create_commits,
            'git checkout master',
            "git remote add origin #{origin}"
          ].join(' && ')
        end
      end
    end
  end
end
