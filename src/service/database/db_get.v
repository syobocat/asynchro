module database

import conf
import model

pub fn exists[T](query DBQuery) !bool {
	res := search[T](query)!
	return res.len > 0
}

pub fn get[T](query DBQuery) !T {
	res := search[T](query)!

	one := res[0] or {
		return error('not found')
	}

	return one
}

pub fn get_opt[T](query DBQuery) !DBResult[T] {
	res := search[T](query)!
	return wrap_result[T](res)
}

pub fn search[T](query DBQuery) ![]T {
	db_log(T.name, query)
	if id := query.id {
		if owner := query.owner {
			return search_by_id_and_owner[T](id, owner)
		} else {
			return search_by_id[T](id)
		}
	}

	if alias := query.alias {
		return search_by_alias[T](alias)
	}

	return error('Query cannot be none')
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
		return error('Please use get_schema_by_id() or get_schema_by_url()')
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

fn search_by_alias[T](alias string) ![]T {
	db := conf.data.db

	$if T is Entity {
		res := sql db {
			select from Entity where alias == alias
		}!
		return res
	}
	return error('Not implemented')
}

fn search_by_semantic_id[T](sid string, owner string) ![]T {
	lookup_result := resolve_semanticid(sid, owner)!
	id := lookup_result.result or { return [] }

	return search_by_id[T](id)
}
