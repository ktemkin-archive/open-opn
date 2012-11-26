
require 'serialport'

require_relative 'digest/crc16_opn'

require_relative 'packets/request_time'
require_relative 'packets/request_set_time'

module OpenOPN

  #TODO: move us
  class OPNError < RuntimeError
  end

  class BadResponseError < OPNError
  end
  
  class FailedOperationError < OPNError
  end


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
      time = send_request(Packets::RequestTime.new)

      #And convert that to a ruby time.
      time.to_time()
    end

    #
    #Set the scanner's current date and time.
    #
    def time=(time, allow_failures=false)

      #Create a packet which should set the scanner's current time.
      request = Packets::RequestSetTime.from_time(time)
    
      #Set the time on the scanner, and retrieve the scanner's newly-set reported time.
      new_time = send_request(request).to_time()

      #If the time was not correctly set, throw an error...
      unless new_time.tv_sec == time.tv_sec || allow_failures
        raise FailedOperationError.new("Tried to set the scanner's time to #{time.inspect}, but got back #{new_time.inspect}.")
      end

      new_time
    end

    #
    # Reads a collection of bytes from the barcode scanner directly.
    #
    def read
      @serial_port.read()
    end

    #
    # Sends a given packet
    # 
    def send_request(request)

      #send the request packet over the serial line
      write(request.with_checksum())

      #if this packet expects a response
      unless request.response_format.nil?
        #read the response
        raw_response = read.force_encoding('UTF-8')

        #force it into the proper format
        response = request.response_format.new(raw_response)

        unless response.valid?
          raise BadResponseError.new("A response from the scanner failed its checksum- was #{response.checksum.inspect}, should have been #{response.computed_checksum.inspect}.\n #{response.inspect}")
        end

        response
      end

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
