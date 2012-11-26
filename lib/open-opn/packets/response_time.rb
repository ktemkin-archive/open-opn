
require 'bit-struct'

module OpenOPN
  module Packets

    #
    # Represents Date/Time objects in the OPN2001 format.
    #
    class ResponseTime < BitStruct

      unsigned :command,   24, "Header"

      unsigned :second,   8,  "Seconds past the minute"
      unsigned :minute,   8,  "Minutes past the hour"
      unsigned :hour,     8,  "Hour, in 24-hour format"

      unsigned :day,      8,  "Day"
      unsigned :month,    8,  "Month"
      unsigned :year,     8,  "Year (last two digits)"

      unsigned :eof,      8,  "End of Frame"
      unsigned :checksum, 16, "CRC-16/OPN"

      #
      # Converts the given Time object to a ruby time.
      #
      def to_time
        Time.local(2000 + year, month, day, hour, minute, second)
      end

    end

  end
end

