require "./karere/*"
require "uri"
require "socket"
require "socket/tcp_socket"

module Karere
  class Client
    def initialize(@host : String = "localhost", @port : Int32 = 1883)
    end

    def connect
      socket = TCPSocket.new(@host, @port)
      cp = Connect.new("test_crystal_client")
      socket.write_bytes(cp, IO::ByteFormat::NetworkEndian)
      ca = socket.read_bytes(ControlPacket)
      ca.rc
    end
  end
end
