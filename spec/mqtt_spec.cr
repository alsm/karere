require "./spec_helper"

describe Karere do
  # TODO: Write tests

  it "check packet types" do
    Karere::PacketType::Connect.value.should eq(1)
    Karere::PacketType::Connack.value.should eq(2)
    Karere::PacketType::Publish.value.should eq(3)
    Karere::PacketType::Puback.value.should eq(4)
    Karere::PacketType::Pubrec.value.should eq(5)
    Karere::PacketType::Pubrel.value.should eq(6)
    Karere::PacketType::Pubcomp.value.should eq(7)
    Karere::PacketType::Subscribe.value.should eq(8)
    Karere::PacketType::Suback.value.should eq(9)
    Karere::PacketType::Unsubscribe.value.should eq(10)
    Karere::PacketType::Unsuback.value.should eq(11)
    Karere::PacketType::Pingreq.value.should eq(12)
    Karere::PacketType::Pingresp.value.should eq(13)
    Karere::PacketType::Disconnect.value.should eq(14)
  end

  it "check connect packet" do
    cp = Karere::Connect.new("test_client")
    cp.@fixed_header.packet_type.should eq(1)
    cp.@size.should eq(10)
    io = MemoryIO.new
    cp.to_io(io)
    puts io.to_slice.hexdump
  end

  it "check sending a connect packet" do
    client = Karere::Client.new("127.0.0.1", 1883)
    rc = client.connect
    rc.should eq(1)
  end

  it "check connack packet" do
    cp = Karere::Connack.new
    cp.@fixed_header.packet_type.should eq(2)
  end

  it "check publish packet" do
    cp = Karere::Publish.new
    cp.@fixed_header.packet_type.should eq(3)
  end
end
