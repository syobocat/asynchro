module db

import conf
import model

type Insertable = model.Entity
	| model.Key
	| model.SemanticID
	| model.Profile
	| model.Ack
	| model.Timeline

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
