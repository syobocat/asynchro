module signature

import crypto.sha256
import crypto.sha3
import service.ccid
import v_crypto.ripemd160
import secp256k1

pub fn verify(message []u8, signature []u8, address string) ! {
	hash := sha3.keccak256(message)

	ctx := secp256k1.create_context()!
	defer {
		ctx.destroy()
	}
	pubkey := ctx.ecrecover(hash, signature)!
	pubkey_bytes := ctx.serialize_pubkey_compressed(pubkey)!
	pubkey_address := get_pubkey_address(pubkey_bytes)

	hrp := address.limit(3)

	signature_address := ccid.pubkey_to_addr(pubkey_address, hrp)!

	if address != signature_address {
		return error('Wrong signature: expected ${address}, but got ${signature_address}')
	}

	return
}

pub fn get_pubkey_address(pubkey []u8) []u8 {
	hash := sha256.sum256(pubkey)
	digest := ripemd160.new()
	return digest.sum(hash)
}
