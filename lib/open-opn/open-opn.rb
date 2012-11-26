
require 'serialport'

require_relative 'digest/crc16_opn'

require_relative 'packets/request_time'

module OpenOPN

  # Communications class for the OPN-2001 Barcode scanner
  class Device

    # The read timeout, in milliseconds.
    # Lowering this value decreases the amount of time the device has to respond,
    # resulting in faster (but potentially non-functional) results.
    READ_TIMEOUT = 200

    def initialize(serial_port = "/dev/ttyUSB0", baud_rate=9600)

      #If we were passed a string, use it to create a new serial port connection.
      if serial_port.is_a? String
        serial_port = SerialPort.new(serial_port, 9600)
      end

      #Store the serial port object.
      @serial_port = serial_port
      @serial_port.read_timeout = READ_TIMEOUT
    end

    #
    # Get the scanner's current date & time as a ruby time object.
    #
    def time
      #Parse the raw time into a binary time structure...
      #raw_time = send_command(:get_time) 
      #time = Packets::ReseponseTime.new(raw_time)
      time = send_request(Packets::RequestTime.new)

      p time

      #And convert that to a ruby time.
      time.to_time()
    end

    #
    #Set the scanner's current date and time.
    #
    def time=(time)
      
    end


    def read
      @serial_port.read()
    end

    def send_request(request)

      #send the packet over the serial line, and request a response
      write(request.with_checksum())
      raw_response = read.force_encoding('UTF-8')

      #convert the response into the proper response format
      request.response_format.new(raw_response)

    end

    #
    # Writes a set of bytes to the serial port. 
    # If include_checksum is true, the checksum for the message is appended automatically.
    #
    def write(bytes)
      @serial_port.write(bytes)
    end

  end


end 
