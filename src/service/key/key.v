module key

import encoding.hex
import secp256k1

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
