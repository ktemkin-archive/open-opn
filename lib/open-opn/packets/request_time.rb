
require 'bit-struct'
require_relative 'response_time'
require_relative 'packet'

module OpenOPN
  module Packets

    #
    # Requests the current time from the barcode scanner.
    #
    class RequestTime < Packet

      #Expect a ResponseTime object in response to this request.
      EXPECTED_RESPONSE = ResponseTime

      #And send only the basic command:
      char :command,   24, "Command"
      initial_value.command = "\x0A\x02\x00"
    end

  end
end

