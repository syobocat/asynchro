module timeline

import crypto.sha3
import time
import cdid
import conf
import model
import service.db
import schema
import util

pub fn upsert(document model.TimelineDocument, document_raw string, sig string) !db.Timeline {
	id_by_sid := if semantic_id := document.semantic_id {
		if existing_id := db.resolve_semanticid(semantic_id, document.signer)!.result {
			if db.get_opt[db.Timeline](id: existing_id)!.result == none {
				db.delete_semanticid(semantic_id, document.signer)!
				''
			} else {
				if doc_id := document.id {
					if doc_id != existing_id {
						return error('SemanticID mismatch: expected ${existing_id}, but got ${doc_id}')
					}
				}
				existing_id
			}
		} else {
			''
		}
	} else {
		''
	}

	to_create := (document.id or { id_by_sid }) == ''
	db.get[db.Entity](id: document.signer)! // Ensure that the signer exists

	owner := document.owner or { document.signer }
	tlid := if to_create {
		// Create a new timeline
		hash := sha3.keccak256(document_raw.bytes())
		mut hash10 := [10]u8{}
		for i in 0 .. 10 {
			hash10[i] = hash[i]
		}
		signed_at := time.parse_rfc3339(document.signed_at)!
		id := cdid.new(hash10, signed_at).str()

		res := db.get_opt[db.Timeline](id: id)!
		if res.result != none {
			return error('Timeline with the id ${id} already exists')
		}

		// TODO: Verify Policy

		id
	} else {
		// Update an existing timeline
		id := document.id or { id_by_sid }
		normalized := util.normalize_timeline_id(id)!
		split := normalized.split('@')
		if !util.is_my_domain(split.last()) {
			return error('This timeline is not ours')
		}
		existing_tl := db.get[db.Timeline](id: id)!

		if owner != existing_tl.owner {
			return error('Owner mismatch: expected ${existing_tl.owner}, but got ${owner}')
		}

		// TODO: Verify Policy

		id
	}

	timeline := db.Timeline{
		id:            tlid
		owner:         owner
		author:        document.signer
		indexable:     document.indexable
		schema:        document.schema
		policy:        document.policy
		policy_params: document.policy_params
		document:      document_raw
		signature:     sig
	}
	tl_db := modify_tl_for_database(timeline)!
	db.upsert(tl_db)!
	tl_json := modify_tl_for_json(tl_db)!

	if semantic_id := document.semantic_id {
		new_sid := db.SemanticID{
			id:        semantic_id
			owner:     document.signer
			target:    tl_json.id
			document:  document_raw
			signature: sig
		}
		db.upsert(new_sid)!
	}

	return db.Timeline{
		...tl_json
		id: '${tl_json.id}@${conf.data.host}'
	}
}

// Preprocess
fn modify_tl_for_database(tl db.Timeline) !db.Timeline {
	id := util.normalize_timeline_id(tl.id)!
	schema_id := if tl.schema_id > 0 {
		tl.schema_id
	} else {
		schema.url_to_id(tl.schema)!
	}
	policy_id := if tl.policy_id > 0 || tl.policy == none {
		tl.policy_id
	} else {
		schema.url_to_id(tl.policy or { '' })!
	}
	return db.Timeline{
		...tl
		id:        id
		schema_id: schema_id
		policy_id: policy_id
	}
}

// Postprocess
fn modify_tl_for_json(tl db.Timeline) !db.Timeline {
	id := if tl.id.len == 26 {
		't${tl.id}'
	} else {
		tl.id
	}
	tl_schema := if tl.schema.len > 0 {
		tl.schema
	} else {
		schema.id_to_url(tl.schema_id)!
	}
	policy := if pl := tl.policy {
		pl
	} else {
		schema.id_to_url(tl.policy_id)!
	}

	return db.Timeline{
		...tl
		id:     id
		schema: tl_schema
		policy: policy
	}
}
