module database

import log
import time
import conf

pub struct Subscription implements Insertable, Normalizable {
pub:
	id            string @[primary]
	indexable     bool   @[default: false]
	owner         string
	author        string
	document      string
	signature     string
	schema_id     u32     @[json: '-']
	schema        string  @[sql: '-']
	policy_id     u32     @[json: '-']
	policy        ?string @[sql: '-']
	policy_params ?string @[json: 'policyParams']
	cdate         string
	mdate         string
	// ↑same as Timeline (cannot use embed because of ORM)

	items        []SubscriptionItem @[fkey: 'subscription']
	domain_owned bool               @[default: false; json: 'domainOwned']
}

pub struct SubscriptionItem implements Insertable {
	id            string @[primary]
	subscription  string
	resolver_type u32 @[json: 'resolverType']
	entity        ?string
	domain        ?string
}

fn (sub Subscription) exists() !bool {
	return exists[Subscription](id: sub.id)!
}

fn (sub Subscription) insert() ! {
	db := conf.data.db
	sql db {
		insert sub into Subscription
	}!
	log.info('[DB] Subscription created: ${sub.id}')
}

fn (sub Subscription) update() ! {
	db := conf.data.db
	sql db {
		update Subscription set indexable = sub.indexable, author = sub.author, schema_id = sub.schema_id,
		policy_id = sub.policy_id, policy_params = sub.policy_params, document = sub.document,
		signature = sub.signature, domain_owned = sub.domain_owned, mdate = time.utc().format_rfc3339()
		where id == sub.id
	}!
	log.info('[DB] Subscription updated: ${sub.id}')
}

fn (subitem SubscriptionItem) exists() !bool {
	return exists[SubscriptionItem](id: subitem.id)!
}

fn (subitem SubscriptionItem) insert() ! {
	normalized := normalize_id[Subscription](subitem.subscription)!
	item := SubscriptionItem{
		...subitem
		subscription: normalized
	}
	db := conf.data.db
	sql db {
		insert item into SubscriptionItem
	}!
	log.info('[DB] Item ${subitem.id} added to Subscription ${normalized}')
}

fn (subitem SubscriptionItem) update() ! {
	// No need for updating
	return
}

pub fn (sub Subscription) preprocess() !Subscription {
	id, schema_id, policy_id := preprocess[Subscription](sub)!
	return Subscription{
		...sub
		id:        id
		schema_id: schema_id
		policy_id: policy_id
	}
}

pub fn (sub Subscription) postprocess() !Subscription {
	id, schema, policy := postprocess[Subscription](sub)!
	return Subscription{
		...sub
		id:     id
		schema: schema
		policy: policy
	}
}

fn search_subscription(author string) ![]Subscription {
	db := conf.data.db

	res := sql db {
		select from Subscription where author == author
	}!

	return res
}
