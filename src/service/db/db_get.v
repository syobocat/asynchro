module db

import conf
import model
import util

pub fn get[T](query DBQuery) !DBResult[T] {
	if id := query.id {
		if owner := query.owner {
			return get_by_id_and_owner[T](id, owner)
		} else {
			return get_by_id[T](id)
		}
	}

	if alias := query.alias {
		return get_by_alias[T](alias)
	}

	return error('Query cannot be none')
}

// V does not allow this:
/*
	fn get_by_id[T](id string) !DBResult[T] {
		db := conf.data.db
		sql db {
			select from T where id == id
		}!
		return wrap_result(res)
	}
*/
fn get_by_id[T](id string) !DBResult[T] {
	db := conf.data.db

	$if T is model.Entity {
		res := sql db {
			select from model.Entity where id == id
		}!
		return wrap_result(res)
	}
	$if T is model.Key {
		res := sql db {
			select from model.Key where id == id
		}!
		return wrap_result(res)
	}
	$if T is model.Profile {
		res := sql db {
			select from model.Profile where id == id
		}!
		return wrap_result(res)
	}
	$if T is model.Timeline {
		normalized := util.normalize_timeline_id(id)!
		res := sql db {
			select from model.Timeline where id == normalized
		}!
		return wrap_result(res)
	}
	$if T is model.Acking {
		acks := sql db {
			select from model.Ack where from == id && valid == true
		}!
		acking := model.Acking{
			acks: acks
		}
		return wrap_result([acking])
	}
	$if T is model.Acker {
		acks := sql db {
			select from model.Ack where to == id && valid == true
		}!
		acker := model.Acker{
			acks: acks
		}
		return wrap_result([acker])
	}

	return error('Not implemented')
}

fn get_by_id_and_owner[T](id string, owner string) !DBResult[T] {
	db := conf.data.db

	$if T is model.SemanticID {
		res := sql db {
			select from model.SemanticID where id == id && owner == owner
		}!
		return wrap_result(res)
	}

	return get_by_semantic_id[T](id, owner)
}

fn get_by_alias[T](alias string) !DBResult[T] {
	db := conf.data.db

	$if T is model.Entity {
		res := sql db {
			select from model.Entity where alias == alias
		}!
		return wrap_result(res)
	}
	return error('Not implemented')
}

fn get_by_semantic_id[T](sid string, owner string) !DBResult[T] {
	lookup_result := resolve_semanticid(sid, owner)!
	id := lookup_result.result or { return DBResult[T]{
		result: none
	} }

	return get[T](id: id)
}
