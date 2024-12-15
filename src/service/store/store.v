module store

import encoding.hex
import json
import model
import service.db
import service.entity
import service.key
import service.signature
import util

pub enum CommitMode {
	execute
	dry_run
	local_only_execute
}

pub fn commit(mode CommitMode, document_raw string, sig string, keys ?[]model.Key) !string {
	document := json.decode(model.DocumentBase, document_raw)!
	if document.key_id == '' {
		signature_bytes := hex.decode(sig)!
		signature.verify(document_raw.bytes(), signature_bytes, document.signer)!
	} else {
		res := db.get[model.Entity](id: document.signer)!
		signer := res.result or { return error('no such signer') }
		ccid := if util.is_my_domain(signer.domain) {
			key.get_rootkey_from_subkey(document.key_id)!
		} else {
			trace := keys or {
				return error('document was signed by subkey, but trace was not given')
			}

			key.validate_key_trace(trace)!
		}

		if ccid != document.signer {
			return error('wrong signer')
		}

		signature_bytes := hex.decode(sig)!
		signature.verify(document_raw.bytes(), signature_bytes, document.key_id)!
	}
	match document.type {
		.affiliation {
			affiliation_document := json.decode(model.AffiliationDocument, document_raw)!
			ent := entity.affiliation(affiliation_document, sig)!
			return ent.id
		}
		else {
			return error('not implemented yet')
		}
	}
}
