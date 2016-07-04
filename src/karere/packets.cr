module Karere

enum PacketType : UInt8
	Connect = 1
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



end