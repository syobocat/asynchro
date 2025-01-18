module store

import encoding.hex
import json
import model
import database
import entity
import key
import profile
import signature
import subscription
import timeline
import util

pub enum CommitMode {
	execute
	dry_run
	local_only_execute
}

type Result = database.Entity
	| database.Timeline
	| database.Profile
	| database.Subscription
	| database.SubscriptionItem

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
	if key_id := document.key_id {
		signer := database.get[database.Entity](id: document.signer)!
		ccid := if util.is_my_domain(signer.domain) {
			key.get_rootkey_from_subkey(key_id)!
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
		signature.verify(document_raw.bytes(), signature_bytes, key_id)!
	} else {
		signature_bytes := hex.decode(sig)!
		signature.verify(document_raw.bytes(), signature_bytes, document.signer)!
	}

	match document.type {
		.affiliation {
			ent := entity.affiliation(document_raw, sig)!
			return CommitResult{
				result: ent
			}
		}
		.timeline {
			tl := timeline.upsert(document_raw, sig)!
			return CommitResult{
				result: tl
			}
		}
		.profile {
			pf := profile.upsert(document_raw, sig)!
			return CommitResult{
				result: pf
			}
		}
		.subscription {
			sub := subscription.upsert(document_raw, sig)!
			return CommitResult{
				result: sub
			}
		}
		.subscribe {
			subitem := subscription.subscribe(document_raw, sig)!
			return CommitResult{
				result: subitem
			}
		}
		.unsubscribe {
			subitem := subscription.unsubscribe(document_raw, sig)!
			return CommitResult{
				result: subitem
			}
		}
		else {
			return error('not implemented yet')
		}
	}
}
