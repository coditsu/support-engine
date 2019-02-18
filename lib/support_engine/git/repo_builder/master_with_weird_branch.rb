# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with weird branch name that contains some shell special characters
      class MasterWithWeirdBranch < Base
        # Create changes in a branch
        def self.create_commits
          5.downto(0).flat_map do |number|
            [
              "touch weird-branch-file-#{number}.txt",
              'git add --all ./',
              commit("weird branch commit #{number}", committed_at: number.days.ago)
            ]
          end
        end

        # Steps we need to take in order to setup dummy repository
        BOOTSTRAP_CMD = [
          "git init #{location}",
          "cd #{location}",
          'echo "hash = { \'test\' => 1 }" > master.rb',
          'git add --all ./',
          commit('master commit', committed_at: 30.days.ago),
          'git branch \'#w@eird-branch\'',
          'git checkout \'#w@eird-branch\'',
          create_commits,
          'git checkout master',
          "git remote add origin #{origin}"
        ].join(' && ').freeze
      end
    end
  end
end
