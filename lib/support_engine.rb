# frozen_string_literal: true

%w[
  active_support/inflector
  open3
  require_all
].each { |lib| require lib }

# Shared libraries used across multiple apps
module SupportEngine
  class << self
    # @return [String] root path to this gem
    # @example
    #   SupportEngine.gem_root #=> '/home/user/.gems/support_engine'
    def gem_root
      File.expand_path('../..', __FILE__)
    end
  end
end

require_all File.dirname(__FILE__) + '/**/*.rb'
