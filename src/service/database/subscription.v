module database

import log
import time
import conf

pub struct Subscription implements MutInsertable {
pub:
	indexable     bool @[default: false]
	owner         string
	author        string
	document      string
	signature     string
	policy_params ?string @[json: 'policyParams']
	cdate         string
	mdate         string

	items        []SubscriptionItem @[fkey: 'subscription']
	domain_owned bool               @[default: false; json: 'domainOwned']
pub mut:
	id        string  @[primary]
	schema_id u32     @[json: '-']
	schema    string  @[sql: '-']
	policy_id u32     @[json: '-']
	policy    ?string @[sql: '-']
}

pub enum ResolverType as u32 {
	entity
	domain
}

pub struct SubscriptionItem implements MutInsertable {
pub:
	id            string @[primary]
	resolver_type u32    @[json: 'resolverType']
	entity        ?string
	domain        ?string
pub mut:
	subscription string
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

fn (mut sub Subscription) preprocess() ! {
	sub.id = preprocess_id[Subscription](sub.id)!
	if sub.schema_id == 0 {
		sub.schema_id = schema_url_to_id(sub.schema)!
	}
	if sub.policy_id == 0 {
		if policy := sub.policy {
			sub.policy_id = schema_url_to_id(policy)!
		}
	}
}

fn (mut sub Subscription) postprocess() ! {
	sub.id = postprocess_id[Subscription](sub.id)!
	if sub.schema.len == 0 && sub.schema_id > 0 {
		sub.schema = schema_id_to_url(sub.schema_id)!
	}
	if sub.policy == none && sub.policy_id > 0 {
		sub.policy = schema_id_to_url(sub.policy_id)!
	}
}

fn (sub Subscription) postprocessed() !Subscription {
	mut new := sub
	new.postprocess()!
	return new
}

fn (subitem SubscriptionItem) exists() !bool {
	return exists[SubscriptionItem](id: subitem.id)!
}

fn (subitem SubscriptionItem) insert() ! {
	db := conf.data.db
	sql db {
		insert subitem into SubscriptionItem
	}!
	log.info('[DB] Item ${subitem.id} added to Subscription ${subitem.subscription}')
}

fn (subitem SubscriptionItem) update() ! {
	// No need for updating
	return
}

fn (mut subitem SubscriptionItem) preprocess() ! {
	subitem.subscription = preprocess_id[Subscription](subitem.subscription)!
}

fn (_ SubscriptionItem) postprocess() ! {}

pub fn (subitem SubscriptionItem) delete() ! {
	delete_semanticid(subitem.id, subitem.subscription)!
}

fn delete_subscriptionitem(id string, subscription string) ! {
	db := conf.data.db
	sql db {
		delete from SubscriptionItem where id == id && subscription == subscription
	}!
}

fn search_subscription(author string) ![]Subscription {
	db := conf.data.db

	res := sql db {
		select from Subscription where author == author
	}!

	return res
}

fn search_subscription_item(id string, subscription string) ![]SubscriptionItem {
	db := conf.data.db

	res := sql db {
		select from SubscriptionItem where id == id && subscription == subscription
	}!

	return res
}
