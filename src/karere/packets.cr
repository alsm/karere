module Karere
  enum PacketType : UInt8
    Connect     = 1
    Connack
    Publish
    Puback
    Pubrec
    Pubrel
    Pubcomp
    Subscribe
    Suback
    Unsubscribe
    Unsuback
    Pingreq
    Pingresp
    Disconnect
  end

  connack_rc = {
    0 => "Connection Accepted",
    1 => "Connection Refused: unacceptable protocol version",
    2 => "Connection Refused: identifier rejected",
    2 => "Connection Refused: server unavailable",
    2 => "Connection Refused: bad username or password",
    2 => "Connection Refused: not authorized",
  }

  struct FixedHeader
    property packet_type : UInt8
    property quality_of_service : UInt8
    property duplicate : Bool
    property retained : Bool

    def initialize(@packet_type, @quality_of_service, @duplicate, @retained)
    end
  end

  abstract class ControlPacket
    @fixed_header : FixedHeader = FixedHeader.new(0_u8, 0_u8, false, false)

    def initialize(packet_type : PacketType)
      @fixed_header = FixedHeader.new(packet_type.value, 0_u8, false, false)
    end
  end

  class Connect < ControlPacket
    def initialize
      super(PacketType::Connect)
    end

    def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
    end
  end

  class Connack < ControlPacket
    def initialize
      super(PacketType::Connack)
    end

    def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
    end
  end

  class Publish < ControlPacket
    def initialize
      super(PacketType::Publish)
    end

    def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
    end
  end
end
