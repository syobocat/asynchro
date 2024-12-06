module ccid

import ismyhc.vbech32
import service.secp256k1

pub fn pubkey_to_addr(pubkey []u8, hrp string) !string {
	return vbech32.encode_from_base256(hrp, pubkey)!
}

pub fn pubkey_to_ccid(pubkey []u8) !string {
	return pubkey_to_addr(pubkey, 'con')
}

pub fn pubkey_to_csid(pubkey []u8) !string {
	return pubkey_to_addr(pubkey, 'ccs')
}

pub fn privkey_to_ccid(privkey_hex string) !string {
	pubkey := secp256k1.privkey_to_pubkey(privkey_hex)!

	return pubkey_to_ccid(pubkey)
}

pub fn privkey_to_csid(privkey_hex string) !string {
	pubkey := secp256k1.privkey_to_pubkey(privkey_hex)!

	return pubkey_to_csid(pubkey)
}
