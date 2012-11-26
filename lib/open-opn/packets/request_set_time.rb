
require 'bit-struct'
require_relative 'response_time'
require_relative 'packet'

module OpenOPN
  module Packets

    #
    # Requests the current time from the barcode scanner.
    #
    class RequestSetTime < Packet

      #Expect a ResponseTime object in response to this request.
      EXPECTED_RESPONSE = ResponseTime

      #Define the structure of a SetTime request.
      char :command,      24, "Command"

      unsigned :second,      8,  "Seconds past the minute"
      unsigned :minute,   8,  "Minutes past the hour"
      unsigned :hour,     8,  "Hour, in 24-hour format"

      unsigned :day,      8,  "Day"
      unsigned :month,    8,  "Month"
      unsigned :year,     8,  "Year (last two digits)"

      unsigned :eof,      8,  "End of Frame"
      char     :checksum, 16, "CRC-16/OPN"

      #Specify the pre-defined parts of the packet.
      initial_value.command = "\x09\x02\x06"
      initial_value.eof = 0

      #
      # Factory method which creates a SetTime request from a ruby time object.
      #
      def self.from_time(time)

        #Create a new SetTime request
        packet = RequestSetTime.new ({
          :second => time.sec, :minute => time.min, :hour => time.hour,
          :day => time.day, :month => time.month, :year => (time.year - 2000)
        })

        packet

      end

    end

  end
end

