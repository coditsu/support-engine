# frozen_string_literal: true

module SupportEngine
  # Simple clock for measuring
  class Clock
    # @return [Array]
    def measure
      start = current
      result = yield
      [result, current - start]
    end

    # @return [Integer]
    def current
      Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
    end
  end
end
