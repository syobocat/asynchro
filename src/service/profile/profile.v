module profile

import json
import time
import cdid
import model
import database
import entity
import util

pub fn lookup(sid string, owner string) !database.DBResult[database.Profile] {
	profile_owner := if util.is_ccid(owner) {
		owner
	} else {
		ent := entity.get_by_alias(owner)!
		ent.id
	}
	return database.get_opt[database.Profile](id: sid, owner: profile_owner)
}

pub fn upsert(document_raw string, sig string) !database.Profile {
	document := json.decode(model.ProfileDocument, document_raw)!

	id_by_sid := if semantic_id := document.semantic_id {
		res := database.resolve_or_clean_semanticid[database.Profile](semantic_id, document.signer,
			document.id)!
		res.result or { '' }
	} else {
		''
	}

	to_create := (document.id or { id_by_sid }) == ''
	database.get[database.Entity](id: document.signer)! // Ensure that the signer exists

	profile_id := if to_create {
		// Create a new profile
		id := cdid.generate(document_raw, document.signed_at)!.str()

		if database.exists[database.Profile](id: id)! {
			return error('Profile with the id ${id} already exists')
		}

		// TODO: Verify Policy

		id
	} else {
		// Update an existing profile
		id := document.id or { id_by_sid }

		// TODO: Verify Policy
		// existing_profile := database.get[database.Profile](id: id)!

		id
	}

	now := time.utc().format_rfc3339()
	mut profile := database.Profile{
		id:            profile_id
		author:        document.signer
		schema:        document.schema
		policy:        document.policy
		policy_params: document.policy_params
		document:      document_raw
		signature:     sig
		cdate:         now
		mdate:         now
	}
	profile.preprocess()!
	database.upsert(profile)!
	profile.postprocess()!

	if semantic_id := document.semantic_id {
		new_sid := database.SemanticID{
			id:        semantic_id
			owner:     document.signer
			target:    profile.id
			document:  document_raw
			signature: sig
		}
		database.upsert(new_sid)!
	}

	return profile
}
