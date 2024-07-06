require_relative "../test_helper"

class TimeSlice
  class DurationTest < TestCase
    it "accepts string periods with integer values" do
      assert_equal 1.hour, Duration.new("1h")
      assert_equal 1.minute, Duration.new("1m")
      assert_equal 1.day, Duration.new("1d")
      assert_equal 1.week, Duration.new("1w")
      assert_equal 1.month, Duration.new("1mo")
      assert_equal 1.year, Duration.new("1y")
    end

    it "raises ArgumentError for fractional values" do
      assert_raises(ArgumentError) { Duration.new("1.5h") }
      assert_raises(ArgumentError) { Duration.new("2.5m") }
      assert_raises(ArgumentError) { Duration.new("0.5d") }
    end

    it "raises ArgumentError for invalid durations" do
      assert_raises(ArgumentError) { Duration.new("one day") }
      assert_raises(ArgumentError) { Duration.new("1z") }
    end

    it "converts to a period" do
      assert_equal "1d", Duration.new("1d").period
      assert_equal "2d", Duration.new("2d").period
    end

    it "handles multi-digit values" do
      assert_equal 42.hours, Duration.new("42h")
      assert_equal 100.minutes, Duration.new("100m")
    end

    it "is case sensitive" do
      assert_raises(ArgumentError) { Duration.new("1H") }
      assert_raises(ArgumentError) { Duration.new("1D") }
    end

    it "correctly sets the unit attribute" do
      assert_equal :seconds, Duration.new("1s").unit
      assert_equal :minutes, Duration.new("1m").unit
      assert_equal :hours, Duration.new("1h").unit
      assert_equal :days, Duration.new("1d").unit
      assert_equal :weeks, Duration.new("1w").unit
      assert_equal :months, Duration.new("1mo").unit
      assert_equal :years, Duration.new("1y").unit
    end

    it "handles multiplication correctly" do
      assert_equal 4.hours.to_i, Duration.new("2h") * 2
      assert_equal 6.hours.to_i, Duration.new("2h") * 3
    end

    it "handles edge cases for different units" do
      assert_equal 1.second, Duration.new("1s")
      assert_equal 1.year, Duration.new("1y")
    end

    it "converts larger units to smaller units correctly" do
      assert_equal 60, Duration.new("1h").to_i / Duration.new("1m").to_i
      assert_equal 24, Duration.new("1d").to_i / Duration.new("1h").to_i
      assert_equal 7, Duration.new("1w").to_i / Duration.new("1d").to_i
    end

    it "handles equality comparison" do
      assert_equal Duration.new("1h"), Duration.new("60m")
      refute_equal Duration.new("1h"), Duration.new("59m")
    end
  end
end
