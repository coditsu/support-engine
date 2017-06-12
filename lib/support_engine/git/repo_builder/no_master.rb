# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with no master branch
      class NoMaster < Base
        # Steps we need to take in order to setup dummy repository
        BOOTSTRAP_CMD = [
          "git init #{location}",
          "cd #{location}",
          'echo "hash = { \'test\' => 1 }" > master.rb',
          'git add --all ./',
          "git commit -m 'master commit' --author '#{committer}'",
          'git branch develop',
          'git co develop',
          'echo "hash = { \'test\' => 2 }" > develop.rb',
          'git add --all ./',
          "git commit -m 'develop commit' --author '#{committer}'",
          'git branch different-branch',
          'git checkout different-branch',
          'touch different-branch.txt',
          'git add --all ./',
          "git commit -m 'different-branch commit' --author '#{committer}'",
          'git checkout develop',
          "git remote add origin #{origin}",
          'git branch -D master'
        ].join(' && ').freeze
      end
    end
  end
end
