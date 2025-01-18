module subscription

import database
import json
import time
import cdid
import model
import util

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

pub fn subscribe(document_raw string, sig string) !database.SubscriptionItem {
	document := json.decode(model.SubscribeDocument, document_raw)!

	subscription := database.get[database.Subscription](id: document.subscription)!

	if document.signer != subscription.author {
		return error('You are not authorized to perform this action')
	}

	split := document.target.split('@')
	if split.len != 2 {
		return error('target must contains exactly one `@`')
	}

	resolver := split[1]

	subscription_id := database.normalize_id[database.Subscription](document.subscription)!
	item := if util.is_ccid(resolver) {
		database.SubscriptionItem{
			id:            document.target
			subscription:  subscription_id
			entity:        resolver
			resolver_type: u32(database.ResolverType.entity)
		}
	} else {
		database.SubscriptionItem{
			id:            document.target
			subscription:  subscription_id
			domain:        resolver
			resolver_type: u32(database.ResolverType.domain)
		}
	}

	database.upsert(item)!

	return item
}

pub fn unsubscribe(document_raw string, sig string) !database.SubscriptionItem {
	document := json.decode(model.UnsubscribeDocument, document_raw)!

	item := database.get[database.SubscriptionItem](
		id:           document.target
		subscription: document.subscription
	)!
	subscription := database.get[database.Subscription](id: document.subscription)!

	if document.signer != subscription.author {
		return error('You are not authorized to perform this action')
	}

	item.delete()!

	return item
}
