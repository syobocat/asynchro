module database

import log
import conf
import model

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
		create table EntityMeta
		create table Timeline
		create table Subscription
		create table SubscriptionItem
		create table SemanticID
		create table Profile
		create table KV
		create table model.Key
		create table model.Ack
	}!
}

fn wrap_result[T](results []T) DBResult[T] {
	return DBResult[T]{
		result: if result := results[0] { result } else { none }
	}
}

@[if !prod]
fn db_log(type string, query DBQuery) {
	if id := query.id {
		if owner := query.owner {
			log.debug('[DB] Looking up ${type} by id: ${id}, owner: ${owner}')
		} else {
			log.debug('[DB] Looking up ${type} by id: ${id}')
		}
	}
	if alias := query.alias {
		log.debug('[DB] Looking up ${type} by alias: ${alias}')
	}
}
