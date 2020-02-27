# frozen_string_literal: true

module SupportEngine
  module Shell
    # Sometimes results aren't in utf-8 (rare but occurs) that's why we cast it to utf8 just
    # to be sure that we can work with it
    module Utf8
      class << self
        # Allows to execute shell commands and handle errors, etc later
        #   (won't raise any errors but instead will catch all things)
        # @param command_with_options [String] command that should be executed with
        #   all the arguments and options
        # @param raise_on_invalid_exit [Boolean] raise exception when exit code is not 0
        # @return [Hash] SupportEngine::Shell.call execution hash
        def call(command_with_options, raise_on_invalid_exit: true)
          encode(
            Shell.call(
              command_with_options,
              raise_on_invalid_exit: raise_on_invalid_exit
            )
          )
        end

        # @param path [String, Pathname] path to a place where git repo is
        # @param command [String] command that we want to execute in path context
        # @param raise_on_invalid_exit [Boolean] raise exception when exit code is not 0
        # @return [Hash] SupportEngine::Shell.call execution hash
        def call_in_path(path, command, raise_on_invalid_exit: true)
          encode(
            Shell.call_in_path(
              path,
              command,
              raise_on_invalid_exit: raise_on_invalid_exit
            )
          )
        end

        private

        # Encode execution hash to UTF-8
        # @param result [Hash] SupportEngine::Shell.call execution hash
        # @return [Hash] SupportEngine::Shell.call execution hash encoded in UTF-8
        def encode(result)
          options = { invalid: :replace, undef: :replace, replace: '' }

          {
            stdout: result[:stdout].encode('UTF-8', **options),
            stderr: result[:stderr].encode('UTF-8', **options),
            exit_code: result[:exit_code]
          }
        end
      end
    end
  end
end
