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
    3 => "Connection Refused: server unavailable",
    4 => "Connection Refused: bad username or password",
    5 => "Connection Refused: not authorized",
  }

  Protocol_name  = {0x00_u8, 0x04_u8, 0x4D_u8, 0x51_u8, 0x54_u8, 0x54_u8}
  Protocol_level = 4_u8

  class FixedHeader
    property packet_type : UInt8 = 0_u8
    property quality_of_service : UInt8 = 0_u8
    property duplicate : Bool = false
    property retained : Bool = false

    def initialize(@packet_type, @quality_of_service, @duplicate, @retained)
    end

    def encode : UInt8
      fh = @packet_type << 4
      fh = fh | (@quality_of_service << 1)
      if @duplicate
        fh = fh | (1 << 3)
      end
      if @retained
        fh = fh | 1
      end
      fh
    end

    def initialize(io : IO, @packet_type = 0_u8, @quality_of_service = 0_u8, @duplicate = false, @retained = false)
      if fh = io.read_byte
        @packet_type = fh >> 4
        @quality_of_service = (fh & 0x02) >> 1
        if (fh && 0x08)
          @duplicate = true
        end
        if (fh && 0x01)
          @retained = true
        end
      end
    end
  end

  abstract class ControlPacket
    @fixed_header : FixedHeader = FixedHeader.new(0_u8, 0_u8, false, false)
    @size = 0

    def initialize(packet_type : PacketType, qos : UInt8 = 0_u8, dup : Bool = false, retain : Bool = false)
      @fixed_header = FixedHeader.new(packet_type.value, qos, dup, retain)
    end

    protected def write_remaining_length(io : IO)
      length = @size
      loop do
        digit = (length % 128).to_u8
        length /= 128
        if length > 0
          digit |= 0x80_u8
        end
        io.write_byte(digit)
        if length == 0
          break
        end
      end
    end

    protected def read_remaining_length(io : IO)
      remaining_length = 0_u32
      multiplier = 0_u32
      loop do
        if digit = io.read_byte
          remaining_length |= (digit & 127) << multiplier
          if (digit & 128) == 0
            return remaining_length.to_i
          end
          multiplier += 7
        end
      end
    end

    def self.read_packet(io : IO)
      fh = FixedHeader.new(io)
      cp = case PacketType.new(fh.packet_type)
           when PacketType::Connack
             Connack.new(io, fh)
           when PacketType::Publish
             Publish.new(io, fh)
           end
    end
  end

  class Connect < ControlPacket
    @username : String
    @password : String
    @clean_session : Bool = true
    @keep_alive : UInt16
    @client_identifier : String

    def initialize(@client_identifier : String = "", @username : String = "", @password : String = "", @keep_alive : UInt16 = 30_u16)
      super(PacketType::Connect)
      @size = 10
    end

    protected def encode_flags : UInt8
      flags = 0_u8
      if !@username.empty?
        flags |= 1 << 7
      end
      if !@password.empty?
        flags |= 1 << 6
      end
      if @clean_session
        flags |= 1 << 1
      end
      return flags
    end

    def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
      if !@username.empty?
        @size += @username.bytesize
      end
      if !@password.empty?
        @size += @password.bytesize
      end
      if !@client_identifier.empty?
        @size += @client_identifier.bytesize + 2
      end
      io.write_byte(@fixed_header.encode)
      write_remaining_length(io)
      Protocol_name.each { |x| io.write_byte(x) }
      io.write_byte(Protocol_level)
      io.write_byte(encode_flags)
      io.write_byte((@keep_alive >> 8).to_u8)
      io.write_byte(@keep_alive.to_u8)
      if !@client_identifier.empty?
        io.write_bytes(@client_identifier.bytesize.to_u16, IO::ByteFormat::NetworkEndian)
        @client_identifier.each_byte { |x| io.write_byte(x) }
      end
    end
  end

  class Connack < ControlPacket
    @session_present : Bool = false
    property rc : UInt8 = 255_u8

    def initialize(@rc : UInt8 = 0xFF_u8, @session_present : Bool = false)
      super(PacketType::Connack)
    end

    def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
    end

    def initialize(io : IO, fh : FixedHeader, @session_present : Bool = false)
      @fixed_header = fh
      remaining_length = read_remaining_length(io)
      data = Slice(UInt8).new(remaining_length)
      io.read_fully(data)
      if data[0] & 0x01
        @session_present = true
      end
      @rc = data[1]
    end
  end

  class Publish < ControlPacket
    def initialize
      super(PacketType::Publish)
    end

    def initialize(io : IO, fh : FixedHeader)
    end

    def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
    end
  end
end
