module ccid

import crypto.sha256
import encoding.hex
import ismyhc.vbech32
import v_crypto.ripemd160
import secp256k1

pub fn is_ccid(addr string) bool {
	return addr.len == 42 && addr.limit(3) == 'con' && !addr.contains('.')
}

pub fn generate_privkey_hex() !string {
	ctx := secp256k1.create_context()!
	defer { ctx.destroy() }
	privkey := ctx.generate_privkey()!
	privkey_hex := hex.encode(privkey)

	return privkey_hex
}

pub fn privkey_to_pubkey(privkey_hex string) ![]u8 {
	privkey := hex.decode(privkey_hex)!

	ctx := secp256k1.create_context()!
	defer { ctx.destroy() }
	pubkey := ctx.generate_pubkey_from_privkey(privkey)!
	pubkey_bytes := ctx.serialize_pubkey_compressed(pubkey)!

	return pubkey_bytes
}

pub fn pubkey_to_addr(pubkey []u8, hrp string) !string {
	addr := get_pubkey_address(pubkey)!
	return vbech32.encode_from_base256(hrp, addr)!
}

pub fn pubkey_to_ccid(pubkey []u8) !string {
	return pubkey_to_addr(pubkey, 'con')
}

pub fn pubkey_to_csid(pubkey []u8) !string {
	return pubkey_to_addr(pubkey, 'ccs')
}

pub fn privkey_to_ccid(privkey_hex string) !string {
	pubkey := privkey_to_pubkey(privkey_hex)!

	return pubkey_to_ccid(pubkey)
}

pub fn privkey_to_csid(privkey_hex string) !string {
	pubkey := privkey_to_pubkey(privkey_hex)!

	return pubkey_to_csid(pubkey)
}

pub fn get_pubkey_address(pubkey []u8) ![]u8 {
	hash := sha256.sum256(pubkey)
	mut digest := ripemd160.new()
	digest.write(hash)!
	return digest.sum([])
}
