# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with master branch and multiple committers
      class MasterMultipleCommitters < Base
        # Steps we need to take in order to setup dummy repository
        BOOTSTRAP_CMD = [
          "git init #{location}",
          "cd #{location}",
          'echo "hash = { \'test\' => 1 }" > master.rb',
          'git add --all ./',
          'git commit -m "master commit committer1" --author "Committer1 <committer1@coditsu.io>"',
          'echo "hash = { \'test\' => 2 }" > master.rb',
          'git add --all ./',
          'git commit -m "master commit committer2" --author "Committer2 <committer2@coditsu.io>"',
          'echo "hash = { \'test\' => 3 }" > master.rb',
          'git add --all ./',
          'git commit -m "master commit committer3" --author "Committer3 <committer3@coditsu.io>"',
          'git branch different-branch',
          'git checkout different-branch',
          'touch different-branch.txt',
          'git add --all ./',
          'git commit -m "different-branch commit" --author "Committer1 <committer1@coditsu.io>"',
          'git checkout master',
          "git remote add origin #{origin}"
        ].join(' && ').freeze
      end
    end
  end
end
