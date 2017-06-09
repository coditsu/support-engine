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

      # @param [String, Pathname] path to a place where git repo is
      # @param [String] command that we want to execute in path context
      # @return [Hash] hash with 3 keys describing output
      #   (stdout, stderr, exit_code)
      def call_in_path(path, command, options = { raise_on_invalid_exit: true })
        command = ['cd', path.to_s.shellescape, '&&', command]
        call(command.join(' '), options)
      end
    end
  end
end
