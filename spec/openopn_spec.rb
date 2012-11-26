
require_relative '../lib/open-opn'

#Pull OpenOPN into the main namespace
include OpenOPN

#
# Specification of the OPN-2001 interface to opticon barcode scanners.
#
describe Device do

  #
  # General send/receive.
  #

  describe ".with_checksum" do

    it "should attach a OPN-style CRC16 checksum to the given message" do

      known_values = 
        {"\x06\x02\x06\x21\x13\x15\x07\x0B\x0C\x00" => "\x79\xBD",
         "\x06\x02\x06\x22\x23\x14\x07\x0B\x0C\x00" => "\x49\xB6",
         "\x07\x02\x00" => "\x9E\x3E"}

      known_values.each do |sample_message, checksum|
        Device.with_checksum(sample_message).should == sample_message + checksum

      end
    end
  end

  #
  # Gets/sets the current time.
  #
  

  describe "#time" do

    before :each do

      #the packet that should be sent to the scanner, and a sample response
      request = Device.with_checksum(Device::COMMANDS[:get_time])
      response = "\x06\x02\x06\x21\x13\x15\x07\x0B\x0C\x00\x79\xBD"

      #Set up a mock barcode scanner.
      mock_serial = mock('SerialPort')
      mock_serial.stub!(:read_timeout=)
      mock_serial.should_receive(:write).with(request)
      mock_serial.should_receive(:read).and_return(response)

      #And wrap that scanner with a device.
      @device = Device.new(mock_serial)

    end

    it "should request the current time from the scanner" do
      @device.time
    end

 
    it "understands OPN-2001 format time packets" do
      time = @device.time
      time.should == Time.local(2012, 11, 7, 21, 19, 33) 
    end

  end


  describe "#time=" do

    it "should send the new time to the scanner" do

    end

    it "should verify that the scanner has accepted the change" do

    end

  end




end
