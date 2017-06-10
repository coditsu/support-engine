# frozen_string_literal: true

%w[
  active_support/inflector
  active_support/time
  open3
  require_all
  shellwords
].each { |lib| require lib }

# Shared libraries used across multiple apps
module SupportEngine
  class << self
    # @return [String] root path to this gem
    # @example
    #   SupportEngine.gem_root #=> '/home/user/.gems/support_engine'
    def gem_root
      ::File.expand_path('../..', __FILE__)
    end
  end
end

# Most of the time we won't need Git::RepoBuilder so don't require it by default
require_all(
  Dir.glob(
    File.join(File.dirname(__FILE__), '**', '*.rb')
  ).reject { |f| f.include?('repo_builder') }
)
