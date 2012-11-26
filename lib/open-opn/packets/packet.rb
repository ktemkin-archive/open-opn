
require 'bit-struct'
require_relative '../digest/crc16_opn'

module OpenOPN
  module Packets

    #
    # Generic OPN packet class.
    # 
    class Packet < BitStruct

      EXPECTED_RESPONSE = nil

      #Returns a OPN checksum for the given packet.
      def get_checksum
        Digest::CRC16OPN.digest(to_s)
      end

      #Returns a string representation of the given packet, with checksum.
      def with_checksum
        to_s + get_checksum
      end

      # 
      def response_format
        self.class::EXPECTED_RESPONSE
      end

    end

  end
end

