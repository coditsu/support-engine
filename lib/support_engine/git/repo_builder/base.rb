# frozen_string_literal: true

module SupportEngine
  module Git
    # Helper class that is used to create a dummy repository with some comits
    # on different branches that we can use to check if cloning, etc works as expected
    module RepoBuilder
      # Base class for all repository dummies. It provides an API for building
      # a test repository that will contain commits, etc and will be in a particular
      # state (mirror, bare, etc).
      class Base
        class << self
          # @return [String] Where should we put our test dummy repo
          def location
            ::File.join(SupportEngine.gem_root, 'tmp', "test_repo_#{name}")
          end

          # @return [String] Path to .git folder of our location
          def location_git
            ::File.join(location, '.git')
          end

          # @return [String] Origin poiting to external location
          def origin
            "https://something.origin/#{name}"
          end

          # @return [String] Default committer that is git compatible
          # @example
          #   self.committer #=> 'Committer <committer@coditsu.io>'
          def committer
            Committer.call
          end

          # @return [String] underscored name of current class without modules
          # @example
          #   self.name #=> 'master_mirror'
          def name
            to_s.split('::').last.underscore
          end

          # @param message [String] commit message that we want to have
          # @param author [String] author details in git compatible format
          # @param committed_at [Time, DateTime] time of a commit (now is the default)
          # @return [String] git commit command with proper message, date and author
          def commit(message, author: committer, committed_at: Time.now)
            cmd = []
            cmd << "GIT_COMMITTER_DATE='#{committed_at}'"
            cmd << "git commit -m '#{message}'"
            cmd << "--author '#{author}'"
            cmd.join(' ')
          end

          # Creates a dummy repository in LOCATION with some commits and branches
          def bootstrap
            destroy
            SupportEngine::Shell.call(const_get(:BOOTSTRAP_CMD))
          end

          # Destroys dummy repository directory
          def destroy
            FileUtils.rm_r(location, secure: true) if Dir.exist?(location)
          end
        end
      end
    end
  end
end
