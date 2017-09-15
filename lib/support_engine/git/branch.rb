# frozen_string_literal: true

module SupportEngine
  module Git
    # Module for handling branch related operations
    class Branch < Base
      # When we want to resolve branches, we do that based on refs. Refs containt
      # name prefixes that we don't need so this is a map of prefixes that we have to remove
      # in order to get proper branch names
      UNWANTED_PREFIXES = %w[
        refs/remotes/origin/
        refs/remotes/
        refs/heads/
        refs/
      ].freeze

      # When commit is present in multiple branches, those branches have priority in terms
      # of being returned as the main branch of the commit
      PRIORITIZED_BRANCHES = %w[
        master
        develop
        release
      ].freeze

      # String part that indicated that we're  on a detached commit and we need to exlude
      # it from the branches results
      DETACH_STRING = 'HEAD detached'

      class << self
        # Detects a given commit branch
        # @param path [String, Pathname] path to a place where git repo is
        # @param commit_hash [String] git commit hash for which we want to get branch
        # @return [String] comit branch name
        def commit(path, commit_hash)
          cmd = [
            'git for-each-ref --contains',
            commit_hash,
            '| grep -v \'refs/pull/\' | cat'
          ]

          result = SupportEngine::Shell.call_in_path(path, cmd)
          fail_if_invalid(result)

          # We need to know the main head of the repo, for branch picking
          # In case there are multiple branches containing same commit, we prioritize
          # head as the owner of a commit
          head = Ref.head(path)[:stdout].delete("\n")

          # If the head points to HEAD it means that the repo is in the detach state
          # and we need to pick the latest ref to get a head branch
          head = head == 'HEAD' ? sanitize_branch(Ref.latest(path)) : head

          resolve_branch result[:stdout].split("\n"), commit_hash, head
        end

        # Detects a head commit branch
        # @param path [String, Pathname] path to a place where git repo is
        # @return [String] head branch name
        def head(path)
          head = Ref.head(path)[:stdout].delete("\n")
          head == 'HEAD' ? sanitize_branch(Ref.latest(path)) : head
        end

        # @param path [String, Pathname] path to a place where git repo is
        # @return [Array<String>] list of available branches in the repository
        # @note Won't return detached nor info on the selected branch - just raw list
        def all(path)
          branch_list = SupportEngine::Shell.call_in_path(path, 'git branch -a')
          fail_if_invalid(branch_list)

          branch_list[:stdout]
            .split("\n")
            .each(&:strip!)
            .each { |branch| branch.gsub!('* ', '') }
            .delete_if { |a| a.include?(DETACH_STRING) }
        end

        # Figures out the commit that branch originated from
        # @param path [String, Pathname] path to a place where git repo is
        # @param base_branch [String] branch on which we are on
        # @param default_branch [String] default branch of a repository
        # @return [String] commit that branch originated from
        def originated_from(path, base_branch, default_branch)
          # If the passed branch is the default branch, there is not really a merge-base other than
          # itself. In cases like that, instead of returning a previous commit, we return the
          # same commit that we're on. This will indicate for other parts of the system,
          # that this case should be handled differently.
          candidates = base_branch == default_branch ? [base_branch] : all(path)

          bases = candidates.map do |branch|
            cmd = "git merge-base '#{branch}' '#{base_branch}'"
            SupportEngine::Shell.call_in_path(path, cmd)[:stdout].strip
          end

          show_cmd = [
            'git show -s --format="%ct %H"',
            bases.join(' '),
            ' | sort -r | head -n2'
          ].join(' ')

          SupportEngine::Shell
            .call_in_path(path, show_cmd)[:stdout]
            .split(/\n|\s/)
            .last
        end

        private

        # Figures out the commit branch based on the candidates (if multiple)
        # When we clone from remote bare repository, we get branches with the origin/ prefix
        # and head pointer. Based on that we resolve to the head branch or we pick first one
        # from the list
        # @param each_ref [Array<String>] array with for-each-ref results
        # @return [String, nil] nil if no branch detected for a given commit or a branch name
        #   if found
        def resolve_branch(each_ref, commit_hash, head)
          # We prioritize head branches as main branches of a commit if they are in the head
          return head if each_ref.any? do |candidate|
            candidate.include?('origin/HEAD') || candidate.include?("refs/heads/#{head}")
          end

          # First we select only those branches that not only contain but have our commit as
          # the last one (when we are checkout it will work like that as well). For the head
          # commits this is the most accurate
          candidates = each_ref.select { |ref| ref.start_with?(commit_hash) }
          # And if non like that, we just fallback to all branches and pick the first one
          candidates = each_ref if candidates.empty?

          # We pick only the branch name part as the bash command result contains some noise
          candidates.map! { |candidate| candidate.split("\t").last }

          branch = candidates.find do |candidate|
            PRIORITIZED_BRANCHES.any? { |pb| candidate.include?(pb) }
          end

          # And we pick the first one with and sanitize it to get only the branch name
          (branch || candidates.first).tap(&method(:sanitize_branch))
        end

        # Removes unwanted prefixes from branch name
        # @param branch [String] branch name
        # @return [String] sanitized same branch name
        def sanitize_branch(branch)
          raise SupportEngine::Errors::UnknownBranch unless branch
          UNWANTED_PREFIXES.each { |prefix| branch.gsub!(prefix, '') }
          branch
        end
      end
    end
  end
end
