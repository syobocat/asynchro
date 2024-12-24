module key

import encoding.hex
import json
import time
import model
import service.db
import service.signature
import util

const key_trace_max_depth = 8

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
		if util.is_ccid(current_root) {
			return keys
		}

		key := db.get[model.Key](id: current_root)!
		keys << key
		current_root = key.parent
	}
	return error('reached key_trace_max_depth')
}

pub fn validate_key_trace(trace []model.Key) !string {
	root_key := trace[0].root
	mut next_key := trace[0].id
	for key in trace {
		if key.id != next_key {
			return error('invalid key chain: expected ${next_key}, but got ${key.id}')
		}
		if !is_valid(key) {
			return error('key ${key.id} is expired')
		}
		if key.root != root_key {
			return error('unmatched root key: expected ${root_key}, but got ${key.root}')
		}
		sig := hex.decode(key.enact_signature)!
		signature.verify(key.enact_document.bytes(), sig, key.parent)!

		enact_document := json.decode(model.EnactDocument, key.enact_document)!
		if enact_document.target != key.id {
			return error('target of the enact document of ${key.id} is not that key')
		}
		if enact_document.parent != key.parent {
			return error('parent of the enact document of ${key.id} is not the parent of that key')
		}
		if enact_document.root != key.root {
			return error('root of the enact document of ${key.id} is not the root of that key')
		}
		if util.is_ccid(key.parent) {
			if enact_document.signer != key.parent {
				return error('signer of the enact document of ${key.id} is not the parent of that key')
			}
		} else {
			if enact_document.key_id != key.parent {
				return error('key_id of the enact document of ${key.id} is not the parent of that key')
			}
		}

		next_key = key.parent
	}
	return root_key
}

fn is_valid(key model.Key) bool {
	now := time.utc()
	return key.revoke_document == none && key.valid_since < now && now < key.valid_until
}
