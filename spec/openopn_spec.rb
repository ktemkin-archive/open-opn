
require_relative '../lib/open-opn'
require_relative '../lib/open-opn/packets/packet'

#Pull OpenOPN into the main namespace
include OpenOPN

def simple_transaction_mock(request, response)
      #Set up a mock barcode scanner.
      mock_serial = mock('SerialPort')
      mock_serial.stub!(:read_timeout=)
      mock_serial.should_receive(:write).with(request)
      mock_serial.should_receive(:read).and_return(response)

      mock_serial
end

#
# Specification of the OPN-2001 interface to opticon barcode scanners.
#
describe Device do

  #
  # Gets/sets the current time.
  #
  

  describe "#time" do

    before :each do

      request = "\n\x02\x00]\xAF"
      response = "\x06\x02\x06\x21\x13\x15\x07\x0B\x0C\x00\x79\xBD"
      mock_serial = simple_transaction_mock(request, response)

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

      #the packet that should be sent to the scanner, and a sample response
      request = "\x09\x02\x06\x22\x23\x14\x07\x0B\x0C\x00\x79\x86"
      response = "\x06\x02\x06\x22\x23\x14\x07\x0B\x0C\x00\x49\xB6"
      mock_serial = simple_transaction_mock(request, response)

      #Wrap that scanner with a device.
      device = Device.new(mock_serial)

      #And try setting the time.
      device.time = Time.local(2012, 11, 7, 20, 35, 34)

    end

    it "should return the value reported from the scanner" do

      #Create a simple serial port which always responsds with the same value
      stub_serial = stub({ :read => "\x06\x02\x06\x22\x23\x14\x07\x0B\x0C\x00\x49\xB6", :write => nil, :read_timeout= => nil })
      device = Device.new(stub_serial)

      #Set the device's time to the current time.
      new_time = device.send(:time=, Time.now, true)

      #Verify that we recieved the value that corresponds to our canned response, and not the current time.
      new_time.should == Time.local(2012, 11, 7, 20, 35, 34)
    end

    it "should raise an exception if the scanner reports a value other than the value set" do

      #Create a simple serial port which always responds with an incorrect value.
      stub_serial = stub({ :read => "\x06\x02\x06\x22\x23\x14\x07\x0B\x0C\x00\x49\xB6", :write => nil, :read_timeout= => nil })
      device = Device.new(stub_serial)

      #Set the device's time to the current time, and verify that the incorrect response throws an error.
      expect { (device.time = Time.now) }.to raise_error(FailedOperationError)

    end

  end




end
