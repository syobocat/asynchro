module entity

import time
import conf
import model

pub fn get(key string) !model.DBResult[model.Entity] {
	db := conf.data.db

	entities := sql db {
		select from model.Entity where ccid == key
	}!

	return model.DBResult[model.Entity]{
		result: if entity := entities[0] { entity } else { none }
	}
}

fn search_by_alias(alias string) !model.DBResult[model.Entity] {
	db := conf.data.db

	entities := sql db {
		select from model.Entity where alias == alias
	}!

	return model.DBResult[model.Entity]{
		result: if entity := entities[0] { entity } else { none }
	}
}

fn store(entity model.Entity) ! {
	res := get(entity.ccid)!
	if res.result == none {
		store_new(entity)!
	} else {
		db := conf.data.db
		sql db {
			update model.Entity set domain = entity.domain, affiliation_document = entity.affiliation_document,
			affiliation_signature = entity.affiliation_signature, mdate = time.utc() where ccid == entity.ccid
		}!
	}
}

fn store_new(entity model.Entity) ! {
	db := conf.data.db

	sql db {
		insert entity into model.Entity
	}!
}

fn set_alias(key string, alias string) ! {
	db := conf.data.db

	sql db {
		update model.Entity set alias = alias where ccid == key
	}!
}
