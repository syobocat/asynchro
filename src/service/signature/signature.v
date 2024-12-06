module signature

import crypto.sha3
import service.ccid
import secp256k1

pub fn verify(message []u8, signature []u8, address string) ! {
	hash := sha3.keccak256(message)

	ctx := secp256k1.create_context()!
	defer {
		ctx.destroy()
	}
	pubkey := ctx.ecrecover(hash, signature)!
	pubkey_bytes := ctx.serialize_pubkey_compressed(pubkey)!

	hrp := address.limit(3)

	signature_address := ccid.pubkey_to_addr(pubkey_bytes, hrp)!

	if address != signature_address {
		return error('Wrong signature')
	}

	return
}
