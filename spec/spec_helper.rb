# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

%w[
  byebug
  rubygems
  simplecov
].each do |lib|
  require lib
end

require 'support_engine'

SimpleCov.minimum_coverage 100

# Don't include unnecessary stuff into rcov
SimpleCov.start do
  add_filter '/.bundle/'
  add_filter '/doc/'
  add_filter '/spec/'
  add_filter '/config/'
  merge_timeout 600
end

# Some of the support classes depend on one another, so we have to load them in a
# particular order to make them work
%w[
  base
  master
  no_master
  broken_head_ref
  *
].each do |lib_chunk|
  Dir[
    File.join(
      SupportEngine.gem_root, 'spec', 'support', '**', "#{lib_chunk}.rb"
    )
  ].each { |f| require f }
end

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:suite) do
    # In order to check that mirroring works, we need to bootstrap a dummy repository
    # with some commits in master and non-master branch to ensure that mirroring works
    GitRepoBuilder.bootstrap
  end

  config.after(:suite) do
    # Cleanup of dummy repo and test tmp sources path so we don't leave behind
    # garbage cloned test repositories
    GitRepoBuilder.destroy
  end
end
