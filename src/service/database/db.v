module database

import conf
import model

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

interface Insertable {
	exists() !bool
	update() !
	insert() !
}

pub fn init_db() ! {
	db := conf.data.db
	sql db {
		create table Schema
		create table Entity
		create table Timeline
		create table SemanticID
		create table Profile
		create table model.Key
		create table model.Ack
	}!
}

fn wrap_result[T](results []T) !DBResult[T] {
	return DBResult[T]{
		result: if result := results[0] { result } else { none }
	}
}
