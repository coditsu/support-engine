# frozen_string_literal: true

%w[
  active_support/concern
  active_support/inflector
  active_support/time
  open3
  shellwords
  openssl
  zeitwerk
].each { |lib| require lib }

loader = Zeitwerk::Loader.for_gem

# Custom inflector to handle the rspec name
class Inflector < Zeitwerk::Inflector
  # @param basename [String] base name
  # @param abspath [String] absolute path to the file
  # @return [String] class/module name
  def camelize(basename, abspath)
    return 'RSpecLocator' if basename == 'rspec_locator'

    super
  end
end

loader.inflector = Inflector.new
loader.setup

# Shared libraries used across multiple apps
module SupportEngine
  # Current engine version
  VERSION = '0.1.4'

  class << self
    # @return [String] root path to this gem
    # @example
    #   SupportEngine.gem_root #=> '/home/user/.gems/support_engine'
    def gem_root
      ::File.expand_path('../..', __FILE__)
    end
  end
end

loader.eager_load
