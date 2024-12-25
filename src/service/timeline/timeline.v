module timeline

import json
import time
import cdid
import conf
import model
import database
import util

pub fn upsert(document_raw string, sig string) !database.Timeline {
	document := json.decode(model.TimelineDocument, document_raw)!

	id_by_sid := if semantic_id := document.semantic_id {
		res := database.resolve_or_clean_semanticid[database.Timeline](semantic_id, document.signer,
			document.id)!
		res.result or { '' }
	} else {
		''
	}

	to_create := (document.id or { id_by_sid }) == ''
	database.get[database.Entity](id: document.signer)! // Ensure that the signer exists

	owner := document.owner or { document.signer }
	tlid := if to_create {
		// Create a new timeline
		id := cdid.generate(document_raw, document.signed_at)!.str()

		if database.exists[database.Timeline](id: id)! {
			return error('Timeline with the id ${id} already exists')
		}

		// TODO: Verify Policy

		id
	} else {
		// Update an existing timeline
		id := document.id or { id_by_sid }
		normalized := database.normalize_id[database.Timeline](id)!
		split := normalized.split('@')
		if !util.is_my_domain(split.last()) {
			return error('This timeline is not ours')
		}
		existing_tl := database.get[database.Timeline](id: id)!

		if owner != existing_tl.owner {
			return error('Owner mismatch: expected ${existing_tl.owner}, but got ${owner}')
		}

		// TODO: Verify Policy

		id
	}

	now := time.utc().format_rfc3339()
	timeline := database.Timeline{
		id:            tlid
		owner:         owner
		author:        document.signer
		indexable:     document.indexable
		schema:        document.schema
		policy:        document.policy
		policy_params: document.policy_params
		document:      document_raw
		signature:     sig
		cdate:         now
		mdate:         now
	}
	preprocessed := timeline.preprocess()!
	database.upsert(preprocessed)!
	postprocessed := preprocessed.postprocess()!

	if semantic_id := document.semantic_id {
		new_sid := database.SemanticID{
			id:        semantic_id
			owner:     document.signer
			target:    postprocessed.id
			document:  document_raw
			signature: sig
		}
		database.upsert(new_sid)!
	}

	return database.Timeline{
		...postprocessed
		id: '${postprocessed.id}@${conf.data.host}'
	}
}
