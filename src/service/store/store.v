module store

import encoding.hex
import json
import model
import database
import entity
import key
import signature
import timeline
import util

pub enum CommitMode {
	execute
	dry_run
	local_only_execute
}

type Result = database.Entity | database.Timeline

pub enum CommitStatus {
	ok
	permission_denied
	already_exists
	already_deleted
}

pub struct CommitResult {
pub:
	status CommitStatus = .ok
	result Result
}

pub fn commit(mode CommitMode, document_raw string, sig string, option ?string, keys ?[]model.Key) !CommitResult {
	document := json.decode(model.DocumentBase, document_raw)!
	if document.key_id == '' {
		signature_bytes := hex.decode(sig)!
		signature.verify(document_raw.bytes(), signature_bytes, document.signer)!
	} else {
		signer := database.get[database.Entity](id: document.signer)!
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
			return CommitResult{
				result: ent
			}
		}
		.timeline {
			timeline_document := json.decode(model.TimelineDocument, document_raw)!
			tl := timeline.upsert(timeline_document, document_raw, sig)!
			return CommitResult{
				result: tl
			}
		}
		else {
			return error('not implemented yet')
		}
	}
}
