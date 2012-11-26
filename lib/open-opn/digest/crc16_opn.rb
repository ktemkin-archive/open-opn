
require 'digest/crc16'

module Digest
  class CRC16OPN < CRC16
    INIT_CRC = 0xffff
    XOR_MASK = 0xffff
  end
end
