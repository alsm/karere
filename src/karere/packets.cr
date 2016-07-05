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

  Protocol_name = [0x00_u8, 0x04_u8, 0x4D_u8, 0x51_u8, 0x54_u8, 0x54_u8]
  Protocol_level = 4_u8

  struct FixedHeader
    property packet_type : UInt8
    property quality_of_service : UInt8
    property duplicate : Bool
    property retained : Bool

    def initialize(@packet_type, @quality_of_service, @duplicate, @retained)
    end

    def encode : UInt8
      fh = @packet_type << 4
      fh = fh | (@quality_of_service << 1)
      if @duplicate
        fh = fh | (1<<3)
      end
      if @retained
        fh = fh | 1
      end
      return fh
    end
  end

  abstract class ControlPacket
    @fixed_header : FixedHeader = FixedHeader.new(0_u8, 0_u8, false, false)
    @size = 0

    def initialize(packet_type : PacketType, qos : UInt8 = 0_u8, dup : Bool = false, retain : Bool = false)
      @fixed_header = FixedHeader.new(packet_type.value, qos, dup, retain)
    end

    def remaining_length : Array(UInt8)
      length = @size
      encoded = Array(UInt8).new
      loop do
        digit = (length % 128).to_u8
        length /= 128
        if length > 0
          digit |= 0x80_u8
        end
        encoded << digit
        if length == 0
          break
        end
      end
      return encoded
    end
  end

  class Connect < ControlPacket
    @username : String
    @password : String
    @clean_session : Bool = false
    @keep_alive : UInt16

    def initialize(@username : String = "", @password : String = "", @keep_alive : UInt16 = 30_u16)
      super(PacketType::Connect)
      @size = 10
    end

    def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
      if !@username.empty?
        @size += @username.bytesize
      end
      if !@password.empty?
        @size += @password.bytesize
      end
      buffer = Array(UInt8).new(@size + 4)
      buffer << @fixed_header.encode
      self.remaining_length.each { |x| buffer << x }
      Protocol_name.each { |x| buffer << x }
      buffer << (@keep_alive >> 8).to_u8 
      buffer << @keep_alive.to_u8 
      io.write(Slice.new(buffer.to_unsafe, buffer.size))
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
