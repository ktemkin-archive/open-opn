
require 'bit-struct'
require_relative '../digest/crc16_opn'

module OpenOPN
  module Packets

    #
    # Generic OPN packet class.
    # 
    class Packet < BitStruct

      EXPECTED_RESPONSE = nil

      #
      #Returns a newly-computed OPN checksum for the given packet.
      #
      def computed_checksum
        Digest::CRC16OPN.digest(without_checksum)
      end

      #
      #Returns a string representation of the given packet, with checksum.
      #
      def with_checksum
        without_checksum + computed_checksum
      end

      #
      # Returns a string representation of the given packet, without its checksum.
      #
      def without_checksum
       
        #If we have a checksum, return the packet's value without it.
        if respond_to?(:checksum)
          to_s[0...-2]
        #Otherwise, return the packet as-is.
        else
          to_s
        end

      end

      # 
      def response_format
        self.class::EXPECTED_RESPONSE
      end

      #
      # Determines if the given packet is valid by identifying its checksum.
      #
      def valid?
       
        #If we have a checksum field, then check it against the computed checksum.
        if respond_to?(:checksum)
          checksum.force_encoding('UTF-8') == computed_checksum.force_encoding('UTF-8')
        #Otherwise, assume the packet is valid.
        else
          true
        end

      end

    end

  end
end

