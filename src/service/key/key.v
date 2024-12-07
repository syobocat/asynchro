module key

import encoding.hex
import time
import secp256k1
import ccid
import model

const key_trace_max_depth = 8

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

pub fn get_rootkey_from_subkey(key_id string) !string {
	parent_keys := trace_key(key_id)!

	expired_keys := parent_keys.filter(!is_valid(it))
	if expired_keys.len > 0 {
		return error('key ${expired_keys[0].id} is expired')
	}

	return parent_keys.last().root
}

fn trace_key(key_id string) ![]model.Key {
	mut keys := []model.Key{cap: key_trace_max_depth}

	mut current_root := key_id
	for _ in 0 .. key_trace_max_depth {
		if ccid.is_ccid(current_root) {
			return keys
		}

		key := get(current_root)![0] or { return error('key ${current_root} not found') }
		keys << key
		current_root = key.parent
	}
	return error('reached key_trace_max_depth')
}

fn is_valid(key model.Key) bool {
	now := time.utc()
	return key.revoke_document == none && key.valid_since < now && now < key.valid_until
}
