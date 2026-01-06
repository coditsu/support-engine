# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with master branch
      class MasterWithHistory < Base
        # Create changes for 1 month back
        def self.create_commits
          30.downto(0).flat_map do |number|
            [
              "echo \"hash = { 'test' => #{number} }\" > master.rb",
              'git add --all ./',
              commit("master commit #{number}", committed_at: number.days.ago),
              "git branch different-branch-#{number}",
              "git checkout different-branch-#{number}",
              "touch different-branch-#{number}.txt",
              'git add --all ./',
              commit("different-branch commit #{number}", committed_at: number.days.ago),
              'git checkout master'
            ]
          end
        end

        # Steps we need to take in order to setup dummy repository
        def self.bootstrap_cmd
          [
            "git init #{location}",
            "cd #{location}",
            create_commits,
            'git checkout master',
            "git remote add origin #{origin}"
          ].join(' && ')
        end
      end
    end
  end
end
