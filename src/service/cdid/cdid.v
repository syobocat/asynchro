module cdid

import crypto.sha3
import encoding.base32
import time

const encoder = base32.new_encoding_with_padding('0123456789abcdefghjkmnpqrstvwxyz'.bytes(),
	base32.no_padding)

@[noinit]
pub struct CDID {
pub mut:
	data       [10]u8
	time       i64
	time_bytes [6]u8
}

pub fn generate(document string, rfc3339 string) !CDID {
	hash := sha3.keccak256(document.bytes())
	mut hash10 := [10]u8{}
	for i in 0 .. 10 {
		hash10[i] = hash[i]
	}
	signed_at := time.parse_rfc3339(rfc3339)!
	return CDID.new(hash10, signed_at)
}

fn CDID.new(data [10]u8, t time.Time) CDID {
	mut cdid := CDID{
		data: data
	}
	cdid.set_time(t)
	return cdid
}

fn (mut cdid CDID) set_time(t time.Time) {
	m := t.unix_milli()

	cdid.time = m
	cdid.time_bytes[0] = u8(m >> 40)
	cdid.time_bytes[1] = u8(m >> 32)
	cdid.time_bytes[2] = u8(m >> 24)
	cdid.time_bytes[3] = u8(m >> 16)
	cdid.time_bytes[4] = u8(m >> 8)
	cdid.time_bytes[5] = u8(m)
}

fn (cdid CDID) bytes() []u8 {
	mut bytes := []u8{cap: 16}
	bytes << cdid.data[..]
	bytes << cdid.time_bytes[..]
	return bytes
}

pub fn (cdid CDID) str() string {
	return encoder.encode_to_string(cdid.bytes())
}
