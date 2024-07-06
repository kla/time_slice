# frozen_string_literal: true

require "active_support"
require "active_support/duration"
require "active_support/core_ext/integer/time"
require "rounding"

##
# The TimeSlice class represents a range of time divided into equal intervals.
# It provides functionality for creating, manipulating, and querying time ranges
# with a specified duration.
#
# == Usage
#
# The TimeSlice class can be initialized with a period (interval duration) and
# options for specifying the range:
#
#   TimeSlice.new(period, options = {})
#
# Where:
# * +period+: A string representing the duration of each interval (e.g., "1h" for 1 hour, "30m" for 30 minutes)
# * +options+: A hash that can include +:from+ (start time), +:to+ (end time), and/or +:length+ (number of intervals)
#
# == Examples
#
#   # Create a range from 12:00 to 15:00 with 1-hour intervals
#   range = TimeSlice.new("1h", from: "2019-01-06 12:00", to: "2019-01-06 15:00")
#
#   range.length  # => 4 (12-13, 13-14, 14-15, 15-16)
#   range.index("2019-01-06 14:30:00")  # => 2
#   range.to_a.last  # => [2019-01-06 15:00:00, 2019-01-06 16:00:00]
#
#   # Iterate over the intervals
#   range.each do |start_time, end_time|
#     puts "#{start_time} - #{end_time}"
#   end
#
#   # Get previous intervals
#   prev_range = range.previous("2019-01-06 13:00", 2)
#
class TimeSlice
  include Enumerable
  autoload :Duration, "time_slice/duration"

  attr_reader :duration, :from, :to

  def initialize(period, options = {})
    @duration = Duration.new(period)
    parse_time_options(options)
    set_time_range(options)
  end

  def period
    duration.period
  end

  def length
    ((@to - @from) / duration.to_i).to_i + 1
  end

  def range
    from..to
  end

  def each
    return to_enum(:each) unless block_given?
    length.times { |i| yield(self[i]) }
  end

  def [](index)
    return nil if index >= length
    at = @from + (index * duration.to_i)
    [at, at + duration.to_i]
  end

  def last
    self[length - 1]
  end

  def slice(index, length)
    length.times.map { |i| self[index + i] }.compact
  end

  def index(starts_at)
    starts_at = parse_time(starts_at)
    index = ((starts_at - @from) / duration.to_i).to_i
    index >= 0 && index < length ? index : nil
  end

  def previous(starts_at, n)
    starts_at = parse_time(starts_at) - duration.to_i
    self.class.new(period, to: starts_at, length: n)
  end

  private

  def parse_time_options(options)
    [:from, :to].each do |key|
      options[key] = parse_time(options[key]) if options[key]
    end
    options[:length] = options[:length].to_i if options[:length]
  end

  def parse_time(time)
    time.is_a?(String) ? Time.zone.parse(time) : time
  end

  def set_time_range(options)
    if options[:from] && options[:to]
      @from = options[:from].floor_to(duration)
      @to = options[:to].floor_to(duration)
    elsif options[:from] && options[:length]
      @from = options[:from].floor_to(duration)
      @to = @from + (options[:length] * duration.to_i) - duration.to_i
    elsif options[:to] && options[:length]
      @to = options[:to].floor_to(duration)
      @from = @to - (options[:length] * duration.to_i) + duration.to_i
    elsif options.keys == [:length]
      @to = Time.current.floor_to(duration)
      @from = @to - (options[:length] * duration.to_i) + duration.to_i
    elsif options.keys == [:from]
      @from = options[:from].floor_to(duration)
      @to = Time.current.floor_to(duration)
    end
  end
end
