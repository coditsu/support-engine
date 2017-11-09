# frozen_string_literal: true

module SupportEngine
  # Wrapper for executing shell commands
  # @example Run ls
  #   SupportEngine::Shell.('ls') =>
  #   { stdout: "test.rb\n", stderr: '', exit_code: 0}
  module Shell
    class << self
      # Allows to execute shell commands and handle errors, etc later
      #   (won't raise any errors but instead will catch all things)
      # @param command_with_options [String] command that should be executed with
      #   all the arguments and options
      # @param raise_on_invalid_exit [Boolean] raise exception when exit code is not 0
      # @return [Hash] hash with 3 keys describing output
      #   (stdout, stderr, exit_code)
      # @example Run ls
      #   SupportEngine::Shell.('ls') =>
      #   { stdout: "test.rb\n", stderr: '', exit_code: 0}
      def call(command_with_options, raise_on_invalid_exit: true)
        stdout_str, stderr_str, status = Open3.capture3(command_with_options)

        result = {
          stdout: stdout_str,
          stderr: stderr_str,
          exit_code: status.exitstatus
        }

        raise Errors::FailedShellCommand, result.values.join(': ') \
          if raise_on_invalid_exit && result[:exit_code] != 0

        result
      end

      # @param path [String, Pathname] to a place where git repo is
      # @param command [String] that we want to execute in path context
      # @param raise_on_invalid_exit [Boolean] raise exception when exit code is not 0
      # @return [Hash] hash with 3 keys describing output (stdout, stderr, exit_code)
      def call_in_path(path, command, raise_on_invalid_exit: true)
        command = ['cd', path.to_s.shellescape, '&&', command]
        call(command.join(' '), raise_on_invalid_exit: raise_on_invalid_exit)
      end

      # Escapes any dangerous parameters so we can use a string in a safe way in shell
      # @param shell_string [String] string that we want to escape
      # @return [String] safe shell parameter string
      def escape(shell_string)
        Shellwords.escape(shell_string)
      end
    end
  end
end
