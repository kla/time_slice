require_relative "../test_helper"
require "active_support/time"
require "active_support/core_ext/time/zones"
require "active_support/core_ext/time/calculations"

class TimeSliceTest < TestCase
  let(:range) { TimeSlice.new("2h", length: 2) }
  let(:now) { Time.zone.parse("2019-01-06 17:44:00") }

  before { Time.stubs(current: now) }

  it "accepts a period and :length option" do
    range = TimeSlice.new("2h", length: "4")
    assert_equal 4, range.length
    assert_equal "2019-01-06T10:00:00Z", range.from.iso8601
    assert_equal "2019-01-06T16:00:00Z", range.to.iso8601
    assert_time_range "[2019-01-06T10:00:00Z, 2019-01-06T12:00:00Z]", range[0]
    assert_time_range "[2019-01-06T12:00:00Z, 2019-01-06T14:00:00Z]", range[1]
    assert_time_range "[2019-01-06T14:00:00Z, 2019-01-06T16:00:00Z]", range[2]
    assert_time_range "[2019-01-06T16:00:00Z, 2019-01-06T18:00:00Z]", range[3]

    range = TimeSlice.new("2h", length: 1)
    assert_equal 1, range.length
    assert_time_range "[2019-01-06T16:00:00Z, 2019-01-06T18:00:00Z]", range[0]
  end

  it "is enumerable" do
    assert range.each { true }
    assert_time_range "[[2019-01-06T14:00:00Z, 2019-01-06T16:00:00Z], [2019-01-06T16:00:00Z, 2019-01-06T18:00:00Z]]", range
  end

  it "accepts a :from option" do
    range = TimeSlice.new("5m", from: "2019-01-06 17:20")
    assert_equal "2019-01-06T17:20:00Z", range.from.iso8601
    assert_equal "2019-01-06T17:40:00Z", range.to.iso8601
    assert_time_range "[2019-01-06T17:20:00Z, 2019-01-06T17:25:00Z]", range.first
    assert_time_range "[2019-01-06T17:40:00Z, 2019-01-06T17:45:00Z]", range.last
    assert_equal 5, range.length

    range = TimeSlice.new("1m", from: "2019-01-06 17:20")
    assert_equal "2019-01-06T17:20:00Z", range.from.iso8601
    assert_equal "2019-01-06T17:44:00Z", range.to.iso8601
    assert_time_range "[2019-01-06T17:20:00Z, 2019-01-06T17:21:00Z]", range.first
    assert_time_range "[2019-01-06T17:44:00Z, 2019-01-06T17:45:00Z]", range.last
    assert_equal 25, range.length
  end

  it "accepts a :from and :to option" do
    range = TimeSlice.new("5m", from: "2019-01-06 17:10", to: "2019-01-06 17:35")
    assert_equal "2019-01-06T17:10:00Z", range.from.iso8601
    assert_equal "2019-01-06T17:35:00Z", range.to.iso8601
    assert_time_range "[2019-01-06T17:10:00Z, 2019-01-06T17:15:00Z]", range.first
    assert_time_range "[2019-01-06T17:35:00Z, 2019-01-06T17:40:00Z]", range.last
    assert_equal 6, range.length

    range = TimeSlice.new("5m", from: "2019-01-06 17:10:00", to: "2019-01-06 17:10:05")
    assert_equal "2019-01-06T17:10:00Z", range.from.iso8601
    assert_equal "2019-01-06T17:10:00Z", range.to.iso8601
    assert_time_range "[2019-01-06T17:10:00Z, 2019-01-06T17:15:00Z]", range.first
    assert_time_range "[2019-01-06T17:10:00Z, 2019-01-06T17:15:00Z]", range.last
    assert_equal 1, range.length
  end

  it "accepts a :from and :length option" do
    range = TimeSlice.new("5m", from: "2019-01-06 17:10", length: 3)
    assert_equal "2019-01-06T17:10:00Z", range.from.iso8601
    assert_equal "2019-01-06T17:20:00Z", range.to.iso8601
    assert_time_range "[2019-01-06T17:10:00Z, 2019-01-06T17:15:00Z]", range.first
    assert_time_range "[2019-01-06T17:20:00Z, 2019-01-06T17:25:00Z]", range.last
    assert_equal 3, range.length
  end

  it "can be sliced" do
    assert_equal [ range.first ], range.slice(0, 1)
    assert_equal [ range[0], range[1] ], range.slice(0, 2)
    assert_equal [ range[0], range[1] ], range.slice(0, 10)
  end

  it "returns an index for a time" do
    range = TimeSlice.new("5m", length: 5)
    assert_equal 0, range.index("2019-01-06 17:20:00")
    assert_equal 0, range.index("2019-01-06 17:20:30")
    assert_equal 1, range.index("2019-01-06 17:25:00")
    assert_equal 4, range.index("2019-01-06 17:40:00")
    assert_equal 4, range.index("2019-01-06 17:40:30")
    assert_nil range.index("2019-01-06 17:45:00")
    assert_equal 5, range.length
  end

  it "gets previous times" do
    range = TimeSlice.new("5m", from: "2019-01-06 17:00", to: "2019-01-06 17:35")
    prev = range.previous("2019-01-06 17:20:00", 3)
    assert_equal "2019-01-06T17:05:00Z", prev.from.iso8601
    assert_equal "2019-01-06T17:15:00Z", prev.to.iso8601
    assert_time_range "[2019-01-06T17:05:00Z, 2019-01-06T17:10:00Z]", prev[0]
    assert_time_range "[2019-01-06T17:10:00Z, 2019-01-06T17:15:00Z]", prev[1]
    assert_time_range "[2019-01-06T17:15:00Z, 2019-01-06T17:20:00Z]", prev[2]
    assert_equal 3, prev.length
  end

  it "calculates correct length with inclusive end time" do
    range = TimeSlice.new("1h", from: "2019-01-06 12:00", to: "2019-01-06 15:00")
    assert_equal 4, range.length  # 12-13, 13-14, 14-15, 15-16
  end

  it "correctly handles different time periods" do
    range = TimeSlice.new("15m", from: "2019-01-06 12:00", to: "2019-01-06 13:00")
    assert_equal 5, range.length
    assert_time_range "[2019-01-06T12:00:00Z, 2019-01-06T12:15:00Z]", range.first
    assert_time_range "[2019-01-06T13:00:00Z, 2019-01-06T13:15:00Z]", range.last

    range = TimeSlice.new("1d", from: "2019-01-01", to: "2019-01-05")
    assert_equal 5, range.length
    assert_time_range "[2019-01-01T00:00:00Z, 2019-01-02T00:00:00Z]", range.first
    assert_time_range "[2019-01-05T00:00:00Z, 2019-01-06T00:00:00Z]", range.last
  end

  it "handles empty ranges" do
    range = TimeSlice.new("1h", from: "2019-01-06 12:00", to: "2019-01-06 12:00")
    assert_equal 1, range.length
    assert_time_range "[2019-01-06T12:00:00Z, 2019-01-06T13:00:00Z]", range.first
    assert_time_range "[2019-01-06T12:00:00Z, 2019-01-06T13:00:00Z]", range.last
  end

  it "correctly implements the Enumerable interface" do
    range = TimeSlice.new("1h", from: "2019-01-06 12:00", to: "2019-01-06 14:00")
    assert_equal 3, range.count
    assert_equal Time.zone.parse("2019-01-06 12:00:00"), range.first.first
    assert_equal Time.zone.parse("2019-01-06 13:00:00"), range.first.last
    assert_equal Time.zone.parse("2019-01-06 14:00:00"), range.to_a.last.first
    assert_equal Time.zone.parse("2019-01-06 15:00:00"), range.to_a.last.last

    collected_times = range.map { |start, end_time| [start.strftime("%H:%M"), end_time.strftime("%H:%M")] }
    assert_equal [["12:00", "13:00"], ["13:00", "14:00"], ["14:00", "15:00"]], collected_times

    assert range.any? { |start, _| start.hour == 13 }
    assert_equal 2, range.select { |start, _| start.hour >= 13 }.count
  end

  it "handles inclusive end times correctly" do
    range = TimeSlice.new("1h", from: "2019-01-06 12:00", to: "2019-01-06 14:00")
    assert_equal 3, range.length
    assert_equal Time.zone.parse("2019-01-06 14:00:00"), range.to_a.last.first
    assert_equal Time.zone.parse("2019-01-06 15:00:00"), range.to_a.last.last
  end

  it "handles slice method edge cases" do
    range = TimeSlice.new("1h", from: "2019-01-06 12:00", to: "2019-01-06 15:00")
    assert_equal [], range.slice(4, 1)
    assert_equal 2, range.slice(2, 3).length
  end

  it "correctly handles previous method with edge cases" do
    range = TimeSlice.new("1h", from: "2019-01-06 12:00", to: "2019-01-06 15:00")
    prev = range.previous("2019-01-06 13:00", 2)
    assert_time_range "[2019-01-06T11:00:00Z, 2019-01-06T12:00:00Z]", prev.first
    assert_time_range "[2019-01-06T12:00:00Z, 2019-01-06T13:00:00Z]", prev.last

    prev = range.previous("2019-01-06 12:00", 2)
    assert_time_range "[2019-01-06T10:00:00Z, 2019-01-06T11:00:00Z]", prev.first
    assert_time_range "[2019-01-06T11:00:00Z, 2019-01-06T12:00:00Z]", prev.last
  end
end
