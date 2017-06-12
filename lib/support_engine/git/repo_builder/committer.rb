# frozen_string_literal: true

module SupportEngine
  module Git
    module RepoBuilder
      # Default committer
      class Committer
        class << self
          # Full name and email
          def call
            "#{name} <#{email}>"
          end

          # Full name
          def name
            'Committer'
          end

          # Email
          def email
            'committer@coditsu.io'
          end
        end
      end
    end
  end
end
