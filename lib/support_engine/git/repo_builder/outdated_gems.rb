# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Creates repository with outdated gems
      class OutdatedGems < Base
        class << self
          # @return [String] Gemfile with outdated rails gem
          def gemfile
            <<~GEMFILE
              # frozen_string_literal: true

              source 'https://rubygems.org'
              ruby '2.4.1'

              gem 'bcrypt'
            GEMFILE
          end

          # @return [String] Gemfile.lock with outdated rails gem
          def gemfile_lock
            <<~GEMFILE
              GEM
                remote: https://rubygems.org/
                specs:
                  bcrypt (3.1.10)

              PLATFORMS
                ruby

              DEPENDENCIES
                bcrypt

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
