require "minitest/autorun"
require "mocha/minitest"
require_relative "../lib/time_slice"

Time.zone = "UTC"

class TestCase < Minitest::Spec
  def time_array_to_s(times)
    nested = true
    unless times[0].is_a?(Array)
      nested = false
      times = [times]
    end

    times = times
      .map { |times| times.map { |t| t.to_fs(:db) } }
      .map { |times| "[#{times.join(", ")}]" }
      .join(", ")

    nested ? "[#{times}]" : times
  end

  def assert_time_range(expected, time_ranges)
    assert_equal expected, time_array_to_s(time_ranges)
  end
end
