module ccid

import crypto.sha256
import ismyhc.vbech32
import v_crypto.ripemd160
import service.key

pub fn pubkey_to_addr(pubkey []u8, hrp string) !string {
	addr := get_pubkey_address(pubkey)
	return vbech32.encode_from_base256(hrp, addr)!
}

pub fn pubkey_to_ccid(pubkey []u8) !string {
	return pubkey_to_addr(pubkey, 'con')
}

pub fn pubkey_to_csid(pubkey []u8) !string {
	return pubkey_to_addr(pubkey, 'ccs')
}

pub fn privkey_to_ccid(privkey_hex string) !string {
	pubkey := key.privkey_to_pubkey(privkey_hex)!

	return pubkey_to_ccid(pubkey)
}

pub fn privkey_to_csid(privkey_hex string) !string {
	pubkey := key.privkey_to_pubkey(privkey_hex)!

	return pubkey_to_csid(pubkey)
}

pub fn get_pubkey_address(pubkey []u8) []u8 {
	hash := sha256.sum256(pubkey)
	digest := ripemd160.new()
	return digest.sum(hash)
}
