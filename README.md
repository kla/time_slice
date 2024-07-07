# TimeSlice

TimeSlice is a Ruby gem that provides functionality for creating, manipulating, and querying time ranges with specified durations. It's particularly useful for working with time-based data in applications that require precise time interval handling.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'time_slice'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install time_slice
```

## Usage

### TimeSlice

The `TimeSlice` class represents a range of time divided into equal intervals.

#### Initialization

```ruby
TimeSlice.new(period, options = {})
```

- `period`: A string representing the duration of each interval (e.g., "1h" for 1 hour, "30m" for 30 minutes)
- `options`: A hash that can include `:from` (start time), `:to` (end time), and/or `:length` (number of intervals)

#### Examples

```ruby
# Create a range from 12:00 to 15:00 with 1-hour intervals
range = TimeSlice.new("1h", from: "2019-01-06 12:00", to: "2019-01-06 15:00")

range.length  # => 4 (12-13, 13-14, 14-15, 15-16)
range.index("2019-01-06 14:30:00")  # => 2
range.to_a.last  # => [2019-01-06 15:00:00, 2019-01-06 16:00:00]

# Iterate over the intervals
range.each do |start_time, end_time|
  puts "#{start_time} - #{end_time}"
end

# Get previous intervals
prev_range = range.previous("2019-01-06 13:00", 2)
```

### Duration

The `TimeSlice::Duration` class extends `ActiveSupport::Duration` to provide a more flexible way of specifying and working with time durations.

#### Supported Units

- s: seconds
- m: minutes
- h: hours
- d: days
- w: weeks
- mo: months
- y: years

#### Usage

```ruby
TimeSlice::Duration.new("5m")  # => 5 minutes
TimeSlice::Duration.new("2h")  # => 2 hours
TimeSlice::Duration.new("1d")  # => 1 day

duration = TimeSlice::Duration.new("3h")
duration.unit  # => :hours
duration.period  # => "3h"
duration * 2  # => 21600 (number of seconds in 6 hours)
```

## Dependencies

- activesupport
- rounding

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
