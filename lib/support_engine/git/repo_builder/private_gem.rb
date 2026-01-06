# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with private gem
      class PrivateGem < Base
        class << self
          # @return [String] Gemfile with private gem
          def gemfile
            <<~GEMFILE
              # frozen_string_literal: true

              source 'https://rubygems.org'
              ruby '2.4.1'

              gem 'private_gem', git: 'git@github.com:servercrunch/private-gem.git'
            GEMFILE
          end

          # @return [String] Gemfile.lock with private gem
          def gemfile_lock
            <<~GEMFILE
              GIT
                remote: git@github.com:servercrunch/private-gem.git
                revision: 80cd253c77c22458e0884e67efd8b311b855db05
                specs:
                  private_gem (0.0.1)

              GEM
                remote: https://rubygems.org/
                specs:

              PLATFORMS
                ruby

              DEPENDENCIES
                private_gem!

              RUBY VERSION
                ruby 2.4.1p111

              BUNDLED WITH
                1.15.1
            GEMFILE
          end
        end

        # Steps we need to take in order to setup dummy repository
        def self.bootstrap_cmd
          [
            "git init #{location}",
            "cd #{location}",
            "printf \"#{gemfile}\" > Gemfile",
            "printf \"#{gemfile_lock}\" > Gemfile.lock",
            'git add --all ./',
            commit('master commit'),
            "git remote add origin #{origin}"
          ].join(' && ')
        end
      end
    end
  end
end
