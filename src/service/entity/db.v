module entity

import time
import conf
import model

// V does not support Result of Option
pub fn get(key string) ![]model.Entity {
	db := conf.data.db

	entities := sql db {
		select from model.Entity where ccid == key
	}!

	return entities
}

fn store(entity model.Entity) ! {
	existence := get(entity.ccid)!
	if _ := existence[0] {
		db := conf.data.db
		sql db {
			update model.Entity set domain = entity.domain, affiliation_document = entity.affiliation_document,
			affiliation_signature = entity.affiliation_signature, mdate = time.utc() where ccid == entity.ccid
		}!
	} else {
		store_new(entity)!
	}
}

fn store_new(entity model.Entity) ! {
	db := conf.data.db

	sql db {
		insert entity into model.Entity
	}!
}
