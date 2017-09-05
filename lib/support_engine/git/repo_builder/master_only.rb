# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with master branch only
      class MasterOnly < Base
        # Steps we need to take in order to setup dummy repository
        BOOTSTRAP_CMD = [
          "git init #{location}",
          "cd #{location}",
          'echo "hash = { \'test\' => 1 }" > master.rb',
          'git add --all ./',
          commit('master commit', committed_at: 2.days.ago),
          'echo "hash = { \'test\' => 2 }" > master.rb',
          'git add --all ./',
          commit('master commit 2', committed_at: 1.days.ago),
          'echo "hash = { \'test\' => 3 }" > master.rb',
          'git add --all ./',
          commit('master commit 3', committed_at: 0.days.ago),
          "git remote add origin #{origin}"
        ].join(' && ').freeze
      end
    end
  end
end
