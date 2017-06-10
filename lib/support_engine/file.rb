# frozen_string_literal: true

module SupportEngine
  # Wrapper for file operations
  module File
    class << self
      # Regexp to select encoding details from file -bi command resulsts
      CHARSET_DETECT_REGEXP = /charset=(.*)\n/

      # We need to detect encoding because not all files are in utf8
      # @param path [String] path to a file for which we want to check encoding
      # return [String] encoding of a given file
      def encoding(path)
        command_options = Gem::Platform.local.os == 'darwin' ? '-bI' : '-bi'
        result = SupportEngine::Shell.call("file #{command_options} #{path}")
        result[:stdout].match(CHARSET_DETECT_REGEXP)&.captures&.first || 'utf-8'
      end
    end
  end
end
