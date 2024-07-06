# frozen_string_literal: true

##
# The Duration class extends ActiveSupport::Duration to provide a more
# flexible way of specifying and working with time durations.
#
# It allows creation of duration objects from string representations
# and provides methods for working with these durations.
#
# == Supported Units
#
# * s: seconds
# * m: minutes
# * h: hours
# * d: days
# * w: weeks
# * mo: months
# * y: years
#
# == Usage
#
#   Duration.new("5m")  # => 5 minutes
#   Duration.new("2h")  # => 2 hours
#   Duration.new("1d")  # => 1 day
#
# == Examples
#
#   duration = Duration.new("3h")
#   duration.unit  # => :hours
#   duration.period  # => "3h"
#   duration * 2  # => 21600 (number of seconds in 6 hours)
#
class TimeSlice
  class Duration < ActiveSupport::Duration
    MAP = {
      "s" => :seconds,
      "m" => :minutes,
      "h" => :hours,
      "d" => :days,
      "w" => :weeks,
      "mo" => :months,
      "y" => :years,
    }.freeze

    attr_reader :unit

    def initialize(value)
      raise ArgumentError, "Fractional values are not allowed" if value && value.include?('.')

      if value.is_a?(String) && value.match(/([0-9]+)([a-z]+)/i).try(:length) == 3 && (@unit = MAP[$2])
        value = $1.to_i
        super(value * PARTS_IN_SECONDS[@unit], @unit => value)
      else
        raise ArgumentError, "#{value} is not a valid duration"
      end
    end

    def period
      @period ||= "#{value / 1.send(@unit)}#{@unit.to_s[0]}"
    end
  end
end
