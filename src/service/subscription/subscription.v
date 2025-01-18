module subscription

import database
import json
import cdid
import model
import time

pub fn upsert(document_raw string, sig string) !database.Subscription {
	document := json.decode(model.SubscriptionDocument, document_raw)!

	owner := document.owner or { document.signer }

	subid := if id := document.id {
		// Update an existing subscription
		existing_sub := database.get[database.Subscription](id: id)!

		if owner != existing_sub.owner {
			return error('Owner mismatch: expected ${existing_sub.owner}, but got ${owner}')
		}

		// TODO: Verify Policy

		id
	} else {
		// Create a new subscription
		id := cdid.generate(document_raw, document.signed_at)!.str()

		if database.exists[database.Subscription](id: id)! {
			return error('Subscription with the id ${id} already exists')
		}

		// TODO: Verify Policy

		id
	}

	now := time.utc().format_rfc3339()
	subscription := database.Subscription{
		id:            subid
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
	preprocessed := subscription.preprocess()!
	database.upsert(preprocessed)!
	postprocessed := preprocessed.postprocess()!

	return postprocessed
}
