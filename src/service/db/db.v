module db

import conf
import model
import util

type Insertable = model.Entity | model.Key | model.SemanticID | model.Profile | model.Ack | model.Timeline

@[params]
pub struct DBQuery {
pub:
	id    ?string
	owner ?string
	alias ?string
}

pub struct DBResult[T] {
pub:
	result ?T
}

pub fn init() ! {
	db := conf.data.db
	sql db {
		create table model.Entity
		create table model.Key
		create table model.SemanticID
		create table model.Profile
		create table model.Ack
	}!
}

fn wrap_result[T](results []T) !DBResult[T] {
	return DBResult[T]{
		result: if result := results[0] { result } else { none }
	}
}

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

	return error('Not implemented')
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

pub fn store_new(record Insertable) ! {
	db := conf.data.db

	match record {
		model.Entity {
			entity := record as model.Entity
			sql db {
				insert entity into model.Entity
			}!
		}
		else {
			return error('Not implemented')
		}
	}
}

pub fn store(record Insertable) ! {
	match record {
		model.Entity { return store_entity(record) }
		else { return error('Not implemented') }
	}
}
