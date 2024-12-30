module database

import conf
import model

@[params]
pub struct DBQuery {
pub:
	// Common
	id    ?string
	owner ?string
	// Entity
	alias ?string
	// Profile
	author ?string // Also used by Subscription
	schema ?string // Also used by Timeline
	// Schema
	schema_id  ?u32
	schema_url ?string
}

pub fn exists[T](query DBQuery) !bool {
	res := search[T](query)!
	return res.len > 0
}

pub fn get[T](query DBQuery) !T {
	res := search[T](query)!

	one := res[0] or { return error('not found') }

	return one
}

pub fn get_opt[T](query DBQuery) !DBResult[T] {
	res := search[T](query)!
	return wrap_result[T](res)
}

pub fn search[T](query DBQuery) ![]T {
	db_log(T.name, query)

	// Common
	if id := query.id {
		if owner := query.owner {
			return search_by_id_and_owner[T](id, owner)
		} else {
			return search_by_id[T](id)
		}
	}

	// Entity
	$if T is Entity {
		if alias := query.alias {
			return search_entity(alias)
		}
	}

	// Profile
	$if T is Profile {
		return search_profile(query.author, query.schema)
	}

	// Schema
	$if T is Schema {
		if id := query.schema_id {
			return get_schema_by_id(id)
		}
		if url := query.schema_url {
			return get_schema_by_url(url)
		}
	}

	$if T is Timeline {
		if schema := query.schema {
			return search_timeline(schema)
		}
	}

	// Subscription
	$if T is Subscription {
		if author := query.author {
			return search_subscription(author)
		}
	}

	return error('Invalid query')
}

// V does not allow this:
/*
	fn search_by_id[T](id string) !DBResult[T] {
		db := conf.data.db
		res := sql db {
			select from T where id == id
		}!
		return res
	}
*/
fn search_by_id[T](id string) ![]T {
	db := conf.data.db

	$if T is Schema {
		res := sql db {
			select from Schema where id == id
		}!
		return res
	}
	$if T is Entity {
		res := sql db {
			select from Entity where id == id
		}!
		return res
	}
	$if T is EntityMeta {
		res := sql db {
			select from EntityMeta where id == id
		}!
		return res
	}
	$if T is model.Key {
		res := sql db {
			select from model.Key where id == id
		}!
		return res
	}
	$if T is Profile {
		normalized := normalize_id[Profile](id)!
		res := sql db {
			select from Profile where id == normalized
		}!
		return res.map(it.postprocess()!)
	}
	$if T is Timeline {
		normalized := normalize_id[Timeline](id)!
		res := sql db {
			select from Timeline where id == normalized
		}!
		return res.map(it.postprocess()!)
	}
	$if T is Subscription {
		normalized := normalize_id[Subscription](id)!
		res := sql db {
			select from Subscription where id == normalized
		}!
		return res.map(it.postprocess()!)
	}
	$if T is SubscriptionItem {
		res := sql db {
			select from SubscriptionItem where id == id
		}!
		return res
	}
	$if T is model.Acking {
		acks := sql db {
			select from model.Ack where from == id && valid == true
		}!
		acking := model.Acking{
			acks: acks
		}
		return [acking]
	}
	$if T is model.Acker {
		acks := sql db {
			select from model.Ack where to == id && valid == true
		}!
		acker := model.Acker{
			acks: acks
		}
		return [acker]
	}

	return error('Not implemented')
}

fn search_by_id_and_owner[T](id string, owner string) ![]T {
	db := conf.data.db

	$if T is SemanticID {
		res := sql db {
			select from SemanticID where id == id && owner == owner
		}!
		return res
	}
	$if T is KV {
		res := sql db {
			select from KV where key == id && owner == owner
		}!
		return res
	}

	return search_by_semantic_id[T](id, owner)
}

fn search_by_semantic_id[T](sid string, owner string) ![]T {
	lookup_result := resolve_semanticid(sid, owner)!
	id := lookup_result.result or { return [] }

	return search_by_id[T](id)
}
