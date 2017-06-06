# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with master branch
      class Master < Base
        # Steps we need to take in order to setup dummy repository
        BOOTSTRAP_CMD = [
          "git init #{location}",
          "cd #{location}",
          'echo "hash = { \'test\' => 1 }" > master.rb',
          'git add --all ./',
          'git commit -m "master commit"',
          'git branch different-branch',
          'git checkout different-branch',
          'touch different-branch.txt',
          'git add --all ./',
          'git commit -m "different-branch commit"',
          'git checkout master'
        ].join(' && ').freeze
      end
    end
  end
end
