module ccid

import encoding.hex
import ismyhc.vbech32
import ismyhc.vsecp256k1

pub fn generate_privkey_hex() !string {
	privkey := vsecp256k1.generate_private_key()!
	privkey_hex := hex.encode(privkey)

	return privkey_hex
}

fn privkey_to_pubkey(privkey_hex string) ![]u8 {
	privkey := hex.decode(privkey_hex)!

	ctx := vsecp256k1.create_context()!
	defer { ctx.destroy() }
	keypair := ctx.create_keypair(privkey)!
	pubkey := ctx.create_xonly_pubkey_from_keypair(keypair)!
	pubkey_bytes := ctx.serialize_xonly_pubkey(pubkey)!

	return pubkey_bytes
}

pub fn privkey_to_ccid(privkey_hex string) !string {
	pubkey := privkey_to_pubkey(privkey_hex)!

	ccid := vbech32.encode_from_base256('con', pubkey)!

	return ccid
}

pub fn privkey_to_csid(privkey_hex string) !string {
	pubkey := privkey_to_pubkey(privkey_hex)!

	csid := vbech32.encode_from_base256('ccs', pubkey)!

	return csid
}
